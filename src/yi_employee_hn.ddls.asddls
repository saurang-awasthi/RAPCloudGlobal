define hierarchy YI_EMPLOYEE_HN
  as parent child hierarchy(
    source YI_EMPLOYEE
    child to parent association _Manager
    start where
      Manager is initial
    siblings order by
      LastName ascending
  )
{
  key Employee,
      Manager

}
