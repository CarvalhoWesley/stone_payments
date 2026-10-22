## v1.2.0

- New Mifare provider methods (`mifareDetectCard`, `mifareAuthenticateSector`, `mifareReadBlock`, `mifareWriteBlock`, value block operations, `mifarePowerOff`, `mifareCancelDetection`);
- New `StoneMifareCashless` with ready-made event card methods (`readCard`, `openCard`, `recharge`, `debit`, `refund`, `format`), using the same block layout as pagseguro_smart_flutter;
- New `StoneMifareCashless.formatAll`: clears all 47 data blocks of a Mifare Classic 1K (block 0 and sector trailers are never touched). `format` keeps clearing only the event blocks;
- Fix: print deeplink now sends the required `align` and `size` for text items (the Stone app crashed without them);
- Updated Stone SDK version (4.20.16). Apps must enable core library desugaring (`desugar_jdk_libs` 2.1.5+);
- Example app reorganized into Provider, Deeplink, Mifare and Logs areas, with a central log;

## v1.0.0

- New method `cancelPayment`;
- New method `cancelPaymentWithAuthorizationCode` ;
- New method `abortPayment`;
- Updated Stone SDK version (4.10.2);

## v0.1.7+4

- Remove package name from manifest;
- Added namespace into build.gradle

## v0.1.7+3
⚠️ **[DEPRECATED] Esta versão contém um bug crítico e não deve ser usada.**  
✅ **Por favor, atualize para [1.2.4]**.

## v0.1.7+2

- Increase documentation;

## v0.1.7

- New Stone SDK version (4.9.2);
- Added support to positivo and gertec devices;
- New method `transaction`;
- Deprecated `payment` method;
- Payment method pix added;
- Payment method voucher added;
- README updated;

## v0.1.4

- New way of print with a list of texts and images;
- Deprecated `printFile` method;

## v0.1.3

- More tests;
- Print receipt of Client and Merchant;
- Fix bugs;

## v0.1.2

- Format code;
- Tests;
- Fix bugs;
- Better description;

## v0.1.1

- Stone Payments basic integration;
- Payment transaction;
- Print image in Base64;
