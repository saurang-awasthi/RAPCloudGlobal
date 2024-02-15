@EndUserText.label: 'Stock Query Demo 01'
@ObjectModel.query.implementedBy: 'ABAP:YCL_PROXY_QUERY01'
@UI:{
    headerInfo:{ typeName: 'Stock List',
                title:{ type: #STANDARD, value: 'Stock_id' },
                description:{ value: 'Stock_nm' } }
}
define root custom entity YC_STOCK_DEMO01
{
      @UI.facet  : [{ id: 'Stock_Info', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Stock Infomation', position: 10 },
                    { id: 'Fund_Info', purpose: #STANDARD, type: #LINEITEM_REFERENCE, label: 'Fund List', position: 20, targetElement: '_fundItems' }]

      @UI.lineItem: [{ position: 10, label: '股票代码' }]
      @UI.identification: [{ position: 10, label: '股票代码' }]
      @ObjectModel.text.element: [ 'Stock_nm' ]
  key Stock_id   : abap.char( 6 );

      @UI.lineItem: [{ position: 20, label: '股票名称' }]
      @UI.identification: [{ position: 20, label: '股票名称' }]
      Stock_nm   : abap.char( 100 );

      @UI.lineItem: [{ position: 30, label: '日期' }]
      @UI.identification: [{ position: 30, label: 'Stock Date' }]
      stock_dt   : abap.char( 10 );

      @UI.lineItem: [{ position: 40, label: '基金数量' }]
      @UI.identification: [{ position: 40, label: 'Fund Count' }]
      fund_cnt   : abap.int4;

      _fundItems : composition [0..*] of YC_FUND_DEMO01;
}
