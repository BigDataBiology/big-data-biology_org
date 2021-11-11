import requests
import json
import yaml

from glob import glob
BDBauthors = {}
for f in glob('../people/*.md'):
    data = yaml.load(open(f).read().split('---')[1])
    BDBauthors[data['name']] = f.split('/')[-1][:-3]

base_url = 'https://api.crossref.org/works/'

def norm_doi(doi):
    for prefix in ['http://doi.org/',
            'https://doi.org/']:
        if doi.startswith(prefix):
            return doi[len(prefix):]
    return doi

def get_doi_meta(doi):
    '''looks up doi metadata on crossref'''
    doi = norm_doi(doi)
    r = requests.get(base_url + doi)
    if r.status_code != 200:
        raise ioerror("yeah, something bad happened")
    data = r.json()
    return data['message']

def reformat_meta(meta):
    [title] = meta['title']
    try:
        [journal] = meta['container-title']
    except:
        print(f'Could not parse journal. Please add manually')
        journal = '?'
    doi = meta['DOI']
    authors = []
    for aut in meta.get('author', []):
        authors.append(f'{aut["given"]} {aut["family"]}')

    print("BDB-Lab AUTHORS")
    for aut in authors:
        if aut in BDBauthors:
            print(f'  - {aut}')

    print("Other AUTHORS")
    for aut in authors:
        if aut not in BDBauthors:
            print(f'  - {aut}')

    print('If there is a problem, please EDIT the output to ensure that spelling is exactly the same as used in BDB-Lab')
    print('\n')
    if not authors:
        import sys
        sys.stderr.write("Author information is missing.\n")
        sys.stderr.write("Proceeding... but check results manually\n")
    for pubkey in [
                'published-print',
                'published-online',
                'published',
                ]:
        if pubkey in meta:
            [date_parts] = meta[pubkey]['date-parts']
            break
    else:
        raise IOError("Date information is missing.\n")

    if len(date_parts) == 3:
        year, month, day = date_parts
    elif len(date_parts) == 2:
        year, month = date_parts
        day = 1
    else:
        raise ValueError(f"Cannot parse date parts of form '{date_parts}'")
    abstract = meta.get('abstract', '')
    return {
        'title': title,
        'authors': authors,
        'short_description': '',
        'abstract': abstract,
        'journal': journal,
        'doi': doi,
        'year': year,
        'date': f'{year}-{month}-{day}',
        }

def main(argv):
    if len(argv) != 3:
        import sys
        sys.stderr.write('Usage:\n')
        sys.stderr.write(f'\t{argv[0]} <DOI> <SLUG>\n')
        sys.exit(1)
    _,doi,slug = argv

    meta = get_doi_meta(doi)
    remeta = reformat_meta(meta)
    ofile = f'{remeta["year"]}_{slug}.yaml'
    with open(ofile, 'wt') as out:
        abstract = remeta['abstract']
        del remeta['abstract']
        out.write('---')
        out.write(yaml.dump(remeta, sort_keys=False))
        out.write('---')
        out.write(abstract)
    print(f'Wrote output to {ofile}')
    print(f'Please do the following')
    print(f'    1. Manually check the content therein')
    print(f'    2. Add a short_description')
    print(f'    3. Add an image to public/images/paper/{remeta["year"]}_{slug}.png')

if __name__ == '__main__':
    import sys
    main(sys.argv)

