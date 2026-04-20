```
            _                _                                   _
           (_)              (_)                                 | |
 _ __ ___   _  _ __   _   _  _  _ __ ___   _   _  ___     _ __  | |
| '_ ` _ \ | || '_ \ | | | || || '_ ` _ \ | | | |/ __|   | '_ \ | |
| | | | | || || | | || |_| || || | | | | || |_| |\__ \ _ | |_) || |
|_| |_| |_||_||_| |_| \__,_||_||_| |_| |_| \__,_||___/(_)| .__/ |_|
                                                         | |
                                             by Codebird |_|
```

> **Note:** This is not the official repository. The original creator is known as Codebird and hosts Minuimus [here](https://birds-are-nice.me/software/minuimus.html).
> This repo main objective is to provide a up-to-date Dockerfile so it's easier to run than installing all the dependencies the project need.

Minuimus is a file optimizer utility script written in Perl. By default, it can be pointed to a file and it will transparently reduce the file size, leaving all pixels/text/audio/metadata intact. Using command line options, it can also run lossy optimizations and conversions.

As well as using it's own methods and four optional supporting binaries, Minuimus is dependent on many established utilities.
It automates the process of calling all of these utilities—including recursively processing and reassembling container files (such as `ZIP`, `EPUB` and `DOCX`), detecting and handling any errors, and running integrity checks on the optimized files to prevent data loss.
Based on which dependencies are installed, Minuimus will process files the best it can, and skip those that have no compatible tool installed.

As is the case for any optimizer, the size reduction achieved by Minuimus is highly dependent upon the input data. Even after extensive testing, the results are too inconsistent to easily quantify. Despite that, here are some examples:

- A collection of PDF files sampled from the-eye.eu was reduced by 10%
- A 500GB sample from the archive.org 'computermagazine' collection was reduced by 22%
- A collection of ePub files from Project Gutenberg was reduced by 5%, as these files are light on images, and ZIP files with no optimizable files inside are reduced only slightly, by about 3%

From the original source, check:

- [Official Page](https://birds-are-nice.me/software/minuimus.html)
- [README](./src/README)
- [CHANGELOG](./src/CHANGELOG)

# Quick Start

Build the docker image:

```bash
docker build -t minuimus --progress=plain --no-cache .
docker run --rm -it minuimus --check-deps
```

Compress a file:

```bash
docker run --rm -it -v "$PWD":/data -w /data minuimus --discard-meta somefile.pdf
```

You can also create an alias to make it easier to run:

```bash
alias minuimus="docker run --rm -it -v "$PWD":/data -w /data minuimus"
minuimus --discard-meta somefile.pdf
```

Or more complex things, such as compressing many comics all at once in parallel:

```
OLD_TOTAL="$( du -Ah . )" ; time caffeinate -dmi bash -c 'find . -print0 -type f \( -iname "*.pdf" -o -iname "*.cbz" -o -iname "*.cbr" \) | xargs -0 -P $(( $(getconf _NPROCESSORS_ONLN) / 2 )) -n 1 docker run --init --rm --entrypoint="" -v "$PWD":/data -w /data minuimus timeout -k 60 3600 /usr/bin/minuimus.pl' ; printf "\nBefore:\n$OLD_TOTAL\n\nNow:\n$( du -Ah . )"
```

`caffeinate` will make sure Mac won't sleep, `_NPROCESSORS_ONLN` is used to run in parallel taking half of available processors and there's a timeout of 1h in case some file takes too long.
