# New project

Template.

## Installation

### Pre-requisites

- Python `>=3.10,<3.13`
- [uv](https://github.com/astral-sh/uv)

#### Getting Started

Once the virtual environment is active, install all dependencies by running:

```bash
just install
```

## Installation via Docker

Build project's image as follows:

```bash
just build
```

The present folder will be mounted at `/workdir`.

## Testing

Run:

```bash
just tests
```

## Usage

See the [notebooks](./notebooks) folder and the [examples](./examples) folder.

## Contributing

Please see [here](./contributing.md).
