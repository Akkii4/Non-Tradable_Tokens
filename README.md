# GovernmentID

GovernmentID is a Solidity smart contract that allows a government to issue and manage digital identity cards for its citizens. The contract is based on the ERC-4671 standard for non-tradable tokens (NTTs) and provides the following functionalities:

- Issue a government ID to a citizen
- Revoke all government ID of an blacklisted citizen
- Return all id's owned by an address
- Return the total number of id's issued
- Return the total number of id holders

## Getting Started

### Prerequisites

- Node.js (version 14 or later)
- npm

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/Akkii4/Non-Tradable_Tokens
   ```

2. Install the dependencies:

   ```
   cd Non-Tradable_Tokens
   npm i
   ```

### Usage

#### Running Tests

You can run the test suite using the following command:

```
npx hardhat test
```

#### Compiling the Contract

To compile the contract to a local Hardhat network, run the following command:

```
npx hardhat compile
```
