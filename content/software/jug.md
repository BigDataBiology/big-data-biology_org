---
title: Jug
meta: Software tools developed by the BDB-Lab
---

[Jug Documentation and Tutorial](https://jug.rtfd.org)

## Short Jug example

Here is a one minute example. Save the following to a file called
`primes.py`:

    from jug import TaskGenerator
    from time import sleep

    @TaskGenerator
    def is_prime(n):
        sleep(1.)
        for j in range(2,n-1):
            if (n % j) == 0:
                return False
        return True

    primes100 = map(is_prime, list(range(2,101)))

Of course, this is only for didactical purposes, normally you would use
a better method. Similarly, the `sleep` function is so that it does not
run too fast.

Now type `jug status primes.py` to get:

    Task name                    Waiting       Ready    Finished     Running
    ------------------------------------------------------------------------
    primes.is_prime                    0          99           0           0
    ........................................................................
    Total:                             0          99           0           0

This tells you that you have 99 tasks called `primes.is_prime` ready to
run. So run `jug execute primes.py &`. You can even run multiple
instances in the background (if you have multiple cores, for example).
After starting 4 instances and waiting a few seconds, you can check the
status again (with `jug status primes.py`):

    Task name                    Waiting       Ready    Finished     Running
    ------------------------------------------------------------------------
    primes.is_prime                    0          63          32           4
    ........................................................................
    Total:                             0          63          32           4

Now you have 32 tasks finished, 4 running, and 63 still ready.
Eventually, they will all finish and you can inspect the results with
`jug shell primes.py`. This will give you an `ipython` shell. The
[primes100]{.title-ref} variable is available, but it is an ugly list of
[jug.Task]{.title-ref} objects. To get the actual value, you call the
[value]{.title-ref} function:

    In [1]: primes100 = value(primes100)

    In [2]: primes100[:10]
    Out[2]: [True, True, False, True, False, True, False, False, False, True]

## Jug links

- [Jug documentation](https://jug.readthedocs.io)
- Jug Manuscript: [Jug: Software for parallel reproducible computation in Python](https://doi.org/10.5334/jors.161) by [Luis Pedro Coelho](/person/luis_pedro_coelho) in _JORS_ 2017

