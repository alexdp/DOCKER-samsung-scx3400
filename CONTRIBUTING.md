# Contributing to Samsung SCX-3400W Docker CUPS

Thank you for considering contributing to this project! We welcome contributions from the community.

## How to Contribute

### Reporting Issues

If you encounter a problem:

1. Check if the issue already exists in the [Issues](https://github.com/alexdp/DOCKER-samsung-scx3400/issues) section
2. If not, create a new issue with:
   - A clear, descriptive title
   - Detailed description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment (OS, Docker version, printer connection type)
   - Relevant logs (use `docker logs samsung-scx3400-cups`)

### Suggesting Enhancements

We welcome suggestions for improvements:

1. Open an issue with the "enhancement" label
2. Describe the enhancement in detail
3. Explain why this would be useful
4. Provide examples if possible

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly:
   - Build the Docker image
   - Test printer functionality
   - Verify documentation updates
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request with:
   - Clear description of changes
   - Reference to related issues
   - Test results

### Code Style

- Use clear, descriptive variable names
- Comment complex sections
- Follow existing code formatting
- Keep commits focused and atomic
- Write meaningful commit messages

### Testing

Before submitting:

- Test Docker build: `docker build -t test-scx3400 .`
- Test container startup: `docker-compose up`
- Verify CUPS web interface is accessible
- Test printer detection (if you have the hardware)
- Check logs for errors

### Documentation

- Update README.md if you change functionality
- Add comments to complex code sections
- Update docker-compose.yml examples if needed
- Document any new environment variables

## Development Setup

1. Clone the repository
2. Make your changes
3. Build and test locally:
   ```bash
   docker-compose build
   docker-compose up -d
   # Test your changes
   docker-compose down
   ```

## Questions?

Feel free to open an issue for questions or reach out to the maintainers.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain a welcoming environment

Thank you for contributing! 🎉
