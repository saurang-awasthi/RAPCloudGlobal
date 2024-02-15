@EndUserText.label: 'Stock Fund Query Demo 01'
@ObjectModel.query.implementedBy: 'ABAP:YCL_PROXY_QUERY01'
@UI.headerInfo:{
    typeName: 'Stock Fund Item',
    typeNamePlural: 'Stock Fund Items',
    title:{ type: #STANDARD, value: 'Fund_id' },
    description:{ type: #STANDARD, value: 'Fund_nm' }

}
@UI.presentationVariant: [{ sortOrder: [{ by: 'Fund_id', direction: #ASC }],
                            visualizations: [{ type: #AS_LINEITEM }] }]
define custom entity YC_FUND_DEMO01
{
      @UI.facet: [{ id : 'General', purpose: #STANDARD, position: 10, label: 'General', type: #IDENTIFICATION_REFERENCE }]
      @UI.hidden: true
  key Stock_id : abap.char( 6 );
      @UI.lineItem: [{ position: 10, label: '基金代码' }]
      @UI.identification: [{ position: 10, label: 'Fund ID' }]
  key Fund_id  : abap.char( 6 );
      @UI.lineItem: [{ position: 20, label: '基金名称' }]
      @UI.identification: [{ position: 20, label: 'Fund Name' }]
      Fund_nm  : abap.char( 100 );
      @UI.lineItem: [{ position: 30, label: '股票占比' }]
      @UI.identification: [{ position: 30, label: '股票占比' }]
      propval  : abap.char( 20 ); -- 占比
      @UI.lineItem: [{ position: 40, label: '持有股数' }]
      @UI.identification: [{ position: 40, label: '持有股数' }]
      holdcnt  : abap.char( 20 ); -- 持有股数
      @UI.lineItem: [{ position: 40, label: '持有金额' }]
      @UI.identification: [{ position: 40, label: '持有金额' }]
      holdamt  : abap.char( 30 ); -- 持有金额

      _StockDT : association to parent YC_STOCK_DEMO01 on $projection.Stock_id = _StockDT.Stock_id;
}
