# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wattson is a personal assistant application built with Python.

## Development Environment

All development and execution happens inside Docker containers for portability.

**Python Tooling (run inside containers):**
- **Testing:** pytest
- **Linting:** flake8
- **Formatting:** black
- **Type Checking:** mypy

**Infrastructure:**
- **Cloud:** AWS (prioritize free tier, optimize for minimal cost)
- **IaC:** Infrastructure as code (anyone can clone and deploy their own instance)
- **Secrets:** Use AWS-native secrets management for all sensitive/environment-specific values
- **Organization:** Resources deployed to dedicated accounts within AWS Organizations

**Principles:**
- AWS-native design first
- Python-first and Pythonic for all code
- Docker for anything involving compute (or justify why an alternative is more ideal)

**AWS Guidance:**
- Follow AWS Cloud Adoption Framework (CAF) and AWS Well-Architected best practices
- Always check for the most recent AWS services and features before implementation
- Prioritize new features and services, especially those in free tier

## Working Style

Work with maximum autonomy. Do not ask for permission to execute tasks - instead, keep the user informed of state, progress, and effectiveness. Share information proactively.

Self-evaluate each step: question if it makes sense and is the best approach. Consider what could go wrong and incorporate prevention into the process by default.
