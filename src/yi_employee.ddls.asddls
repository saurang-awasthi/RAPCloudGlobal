@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy: Employee'
define view entity YI_EMPLOYEE
  as select from ytdemo03
  association of many to one YI_EMPLOYEE as _Manager on $projection.Manager = _Manager.Employee
{

  key ytdemo03.employee   as Employee,
      ytdemo03.first_name as FirstName,
      ytdemo03.last_name  as LastName,
      @Semantics.amount.currencyCode: 'Currency'
      ytdemo03.salary     as Salary,
      ytdemo03.currency   as Currency,
      @EndUserText.label: 'Manager'
      ytdemo03.manager    as Manager,

      _Manager
}
