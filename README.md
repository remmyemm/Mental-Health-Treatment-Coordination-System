# Mental Health Treatment Coordination System

A comprehensive blockchain-based system for coordinating mental health treatment across multiple healthcare providers while maintaining patient privacy and consent management.

## System Overview

This system provides secure, decentralized coordination of mental health treatment through five interconnected smart contracts:

1. **Patient Consent Management** - Manages patient consent for sharing sensitive information
2. **Treatment Plan Coordination** - Coordinates treatment plans between therapists and psychiatrists
3. **Medication Management** - Tracks medications and monitors potential interactions
4. **Crisis Intervention Protocol** - Manages emergency contacts and crisis response procedures
5. **Outcome Measurement** - Tracks treatment effectiveness and patient progress

## Key Features

### Patient Consent Management
- Granular consent controls for different types of information
- Time-limited consent with automatic expiration
- Audit trail of all consent changes
- Emergency override capabilities for crisis situations

### Treatment Plan Coordination
- Collaborative treatment planning between multiple providers
- Version control for treatment plan updates
- Provider role-based access controls
- Treatment goal tracking and progress monitoring

### Medication Management
- Comprehensive medication tracking
- Drug interaction monitoring and alerts
- Dosage history and adjustment tracking
- Integration with treatment plans

### Crisis Intervention Protocol
- Emergency contact management
- Crisis response procedure documentation
- Automatic notification systems
- Emergency access to critical patient information

### Outcome Measurement
- Standardized assessment tracking
- Treatment effectiveness metrics
- Progress visualization and reporting
- Data-driven treatment adjustments

## Contract Architecture

Each contract is designed to be independent while maintaining data consistency through standardized interfaces. The system prioritizes patient privacy and follows healthcare compliance requirements.

### Data Security
- All sensitive data is encrypted
- Access controls based on provider roles
- Audit logging for all data access
- Patient-controlled data sharing permissions

### Provider Coordination
- Multi-provider treatment teams
- Secure communication channels
- Shared treatment protocols
- Coordinated care planning

## Getting Started

1. Install dependencies: `npm install`
2. Run tests: `npm test`
3. Deploy contracts using Clarinet
4. Configure provider access and patient onboarding

## Testing

The system includes comprehensive tests using Vitest to ensure contract functionality and security. Tests cover:
- Contract deployment and initialization
- Patient consent workflows
- Provider coordination scenarios
- Emergency access procedures
- Data integrity and security

## Compliance

This system is designed with healthcare compliance in mind, including:
- HIPAA privacy requirements
- Patient consent management
- Audit trail maintenance
- Secure data handling practices
