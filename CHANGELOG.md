# `SHModelObject` Changelog

## 1.0.8

### New Features 

1. `SHModelObject` now supports automatic parsing of instance variables which are also of type `SHModelObject`
2. `SHModelObject` now supports parsing arrays of objects which are of type `SHModelObject` based on the mapping provided

### Refactoring

1. removed the use of mapping dictionary for date conversion. `SHModelObject` parses the dates based on the instance variable types.