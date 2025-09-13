# print-sigs
Fetch function signatures of Solidity contracts

### Usage

`forge build && print-sigs [--entrypoints] <ContractPath|Directory> <ContractPath|Directory> ... `

### demo

aave v2 lending pool
```bash
➜ bash ./print-sigs.sh --entrypoints src/protocol/lendingpool/LendingPool.sol
## LendingPool

#### external/public mutating


function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf) external nonpayable

function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external nonpayable

function finalizeTransfer(address asset, address from, address to, uint256 amount, uint256 balanceFromBefore, uint256 balanceToBefore) external nonpayable

function flashLoan(address receiverAddress, address[] assets, uint256[] amounts, uint256[] modes, address onBehalfOf, bytes params, uint16 referralCode) external nonpayable

function initReserve(address asset, address aTokenAddress, address stableDebtAddress, address variableDebtAddress, address interestRateStrategyAddress) external nonpayable

function initialize(address provider) external nonpayable

function liquidationCall(address collateralAsset, address debtAsset, address user, uint256 debtToCover, bool receiveAToken) external nonpayable

function rebalanceStableBorrowRate(address asset, address user) external nonpayable

function repay(address asset, uint256 amount, uint256 rateMode, address onBehalfOf) external nonpayable returns (uint256 )

function setConfiguration(address asset, uint256 configuration) external nonpayable

function setPause(bool val) external nonpayable

function setReserveInterestRateStrategyAddress(address asset, address rateStrategyAddress) external nonpayable

function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external nonpayable

function swapBorrowRateMode(address asset, uint256 rateMode) external nonpayable

function withdraw(address asset, uint256 amount, address to) external nonpayable returns (uint256 )
```
