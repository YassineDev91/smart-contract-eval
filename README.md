# Smart Contract Generation Evaluation

This repository contains the dataset, models, and tooling used to evaluate smart contract generation across various Large Language Models (LLMs) and a human expert baseline. It supports transparent comparison of code quality, structural correctness, and compiler safety using a graphical model-to-code workflow.

---

## 📦 Repository Structure

```
smart-contract-eval/
├── contracts-evaluation/       # Solidity outputs from each source
│   ├── ChatGPT/
│   ├── Claude/
│   ├── Gemini/
│   ├── DeepSeek/
│   └── Human/
├── json-models/                # Canonical contract models used as input
│   ├── RemotePurchase.json
│   ├── BlindAuction.json
│   └── HotelInventory.json
├── analysis_reports/           # Full analyzer output from slither and solc
│   └── full_analysis_report.json
├── hardhat-test/               # Runtime validation project using Hardhat v3
│   ├── contracts/              # Smart contracts under test
│   ├── test/                   
│   ├── hardhat.config.ts       # Hardhat configuration
│   └── package.json            
├── solidity_analyzer_combined.py  # Script to generate the evaluation report
├── README.md
└── LICENSE
```

---

## 🧠 Models Evaluated

- ChatGPT (GPT-4o)
- Claude 3
- Gemini 1.5 Pro
- DeepSeek-Coder
- Human Expert (baseline)

All models were prompted using the same structured JSON representation exported from a custom web-based graphical smart contract editor.

---

## 🧱 Contract Use Cases

| Contract Name      | Description                                      |
|--------------------|--------------------------------------------------|
| RemotePurchase     | Buyer-seller escrow with refund logic            |
| BlindAuction       | Auction with sealed bids and deferred reveal     |
| HotelInventory     | Tokenized room offers with availability control  |

All models generated Solidity code from these predefined contract designs.

---

## 📊 Evaluation Methodology

Each generated contract was analyzed using:

- ✅ **`solc` (Solidity compiler)**: AST parsing and syntax validation
- ✅ **`slither`**: Static analysis for vulnerabilities and semantic issues

Results are stored in:
```bash
analysis_reports/full_analysis_report.json
```

Each entry includes:
- `success`: Whether the tool completed without error
- `stdout`/`stderr`: Raw output from solc/slither
- Structured feedback if available

---

## 🧪 Analysis Script

Run the analyzer with:
```bash
python3 solidity_analyzer_combined.py
```

This will:
- Traverse all `.sol` files in `contracts-evaluation/`
- Run `solc` and `slither` on each
- Store combined results in one report file

---

### ⚡ Runtime Validation (Hardhat v3)

The `hardhat-test` folder contains a standalone Hardhat v3 project used to validate the runtime behavior of generated contracts.  
It simulates the full lifecycle of the **RemotePurchase** use case, testing initialization, `confirmPurchase`, `confirmReceived`, and `refundSeller` across all models (ChatGPT, Claude, Gemini, DeepSeek) against the Solidity reference implementation.

#### Features:
- Solidity-based test suite (`Purchase.t.sol`) for reproducible evaluation.
- Cross-contract comparison to highlight functional differences between models.
- Reports on runtime success/failure for each model.

#### Running the Tests:
```bash
cd hardhat-test
npm install
npx hardhat test
```
---

## 📐 JSON Contract Format

The JSON files in `json-models/` follow a platform-agnostic metamodel:
- Supports `Contract`, `Variables`, `Structs`, `Functions`, `Constructor`
- Functional logic is expressed via nested `Statement` blocks:
  - AssignmentStatement
  - ConditionalStatement
  - LoopStatement
  - CallStatement
  - ReturnStatement
  - EmitStatement

---

## 🔬 Scientific Notes

> During early evaluation, Slither output was captured only on success. In this final version, we store both stdout and stderr, ensuring all partial or failed diagnostics are visible in the unified report.

---

## 🧾 Citation

If you use this dataset or script, please cite:
```bibtex
@Article{info16100870,
  AUTHOR = {Ait Hsain, Yassine and Laaz, Naziha and Mbarki, Samir},
  TITLE = {SCEditor-Web: Bridging Model-Driven Engineering and Generative AI for Smart Contract Development},
  JOURNAL = {Information},
  VOLUME = {16},
  YEAR = {2025},
  NUMBER = {10},
  ARTICLE-NUMBER = {870},
  URL = {https://www.mdpi.com/2078-2489/16/10/870},
  ISSN = {2078-2489},
  DOI = {10.3390/info16100870}
}
```

---

## 📄 License

This repository is distributed under the MIT License for academic and non-commercial use.
