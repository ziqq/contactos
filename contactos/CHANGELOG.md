## 1.0.2
- **ADDED**: `iOS` Support for new versions

## 1.0.1
- **FIXED**: Syntax error `!!` intro IOS Plugin

## 1.0.0
- **BREAKING CHANGES**: `FormOperationErrorCode` change options:
                        `FormOperationErrorCode.FORM_OPERATION_CANCELED` => `FormOperationErrorCode.canceled`,
                        `FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN` => `FormOperationErrorCode.couldNotBeOpen`,
                        `FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR` => `FormOperationErrorCode.unknown`
- **BREAKING CHANGES**: Using of plugin from `Contactos.getContacts()` to `Contactos.instance.getContacts()`
- **BREAKING CHANGES**: Rename depend data models:
                       `PostaAddress` => `Contact$PostalAddress`,
                       `Item` => `Contact$Field`
- **BREAKING CHANGES**: `Contact.toMap()` => `Contact.toJson()`
- **CHANGED**: Refactoring

## 0.1.0
- **REMOVED**: deprecated API for `Android`


## 0.0.6
- **CHANGED**: Refactoring


## 0.0.5
- **FIXED**: Formating wrong contact birthday


## 0.0.4
- **CHANGED**: `collection` version `>=1.19.0`


## 0.0.3
- **CHANGED**: `meta` version `>=1.15.0`


## 0.0.2
- **CHANGED**: Refactoring


## 0.0.1
- **ADDED**: Initial release