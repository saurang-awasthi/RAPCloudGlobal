@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy Employee'
@Metadata.allowExtensions: true
@Search.searchable: true
@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'YI_EMPLOYEE_HN' }]
define view entity YC_EMPLOYEE
  as select from YI_EMPLOYEE
  association of many to one YC_EMPLOYEE as _Manager on $projection.Manager = _Manager.Employee
{
  key Employee,

      @Search:{ 
        defaultSearchElement: true,
        fuzzinessThreshold: 0.87
      }
      FirstName,
      @Search:{
        defaultSearchElement: true,
        fuzzinessThreshold: 0.87
      }
      LastName,
      Salary,
      Currency,
      Manager,
      /* Associations */
      _Manager
}
