INTERFACE yif_demo_01
  PUBLIC .
  TYPES: BEGIN OF tp_fund_list,
           fund_id TYPE char6,
           fund_nm TYPE char100,
           propval TYPE char20,   " 占比
           holdcnt TYPE char20,   " 持有股数
           holdamt TYPE char30,   " 持有金额
         END OF tp_fund_list,
         tb_fund_list TYPE STANDARD TABLE OF tp_fund_list WITH KEY fund_id,
         BEGIN OF tp_stock_total,
           stock_id TYPE char6,
           stock_nm TYPE char100,
           stock_dt TYPE char10,
           fund_itm TYPE tb_fund_list,
         END OF tp_stock_total,
         tb_stock_total TYPE STANDARD TABLE OF tp_stock_total WITH KEY stock_id.
  METHODS: mtd_get_stock_list EXPORTING VALUE(et_stock_total) TYPE tb_stock_total.
ENDINTERFACE.
