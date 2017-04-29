global class AppDataSourceConnection extends DataSource.Connection {
    
    global AppDataSourceConnection(DataSource.ConnectionParams connectionParams) {

    }
 
 	override global List<DataSource.Table> sync(){
 		List<DataSource.Table> tables = new List<DataSource.Table>();
 		List<DataSource.Column> columns  = new List<DataSource.Column>();

 		columns.add(DataSource.Column.text('Title', 255));
 		columns.add(DataSource.Column.text('ExternalId', 255));
 		columns.add(DataSource.Column.number('Val', 15, 0));
 		columns.add(DataSource.Column.boolean('TrueOrFalse'));
 		columns.add(DataSource.Column.url('DisplayUrl'));
 		columns.add(DataSource.Column.text('Summary', 255));

 		tables.add(DataSource.Table.get('externalObject', 'Title', columns));

 		return tables;
 	}

    override global DataSource.TableResult query(DataSource.QueryContext context) {
        List<Map<String, Object>>  filteredRows = 
        	DataSource.QueryUtils.filter(context, getRows(context));
        List<Map<String, Object>>  sortedRows = 	
        	DataSource.QueryUtils.sort(context, filteredRows);
        List<Map<String, Object>>  limitedRows = 
        	DataSource.QueryUtils.applyLimitAndOffset(context, sortedRows);
        return DataSource.TableResult.get(context, limitedRows);
    }

    override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
        List<DataSource.TableResult> results =
            new List<DataSource.TableResult>();
        for (DataSource.TableSelection tableSelection :
            context.tableSelections) {
            results.add(DataSource.TableResult.get(tableSelection,
                getRows(context)));
        }
        return results;
    }

    private String makeSummary(){
    	String summary = '';
    	while(summary.length() < 200){
    		if(summary != '')
    			summary += ' ';
    		summary += 'Test sample';
    	}
    	if (!summary.endsWith('.'))
    		summary += '.';
    	summary = summary.capitalize();
    	return summary;
    }

    private List<Map<String, Object>> getRows(DataSource.ReadContext context){
    	List<Map<String, Object>> rows = new List<Map<String, Object>>();

    	for (Integer i = 0; i < 50; i++) {
    		Map<String, Object> row = new Map<String, Object>();

    		String thisId = 'id' + ('00000000' + String.valueOf(i)).right(8);
    		row.put('Title', 'External' + i);
    		row.put('Val', i);
    		row.put('DisplayUrl', 'http://example.com/' + thisId);
    		row.put('TrueOfFalse', i < 30 ? true : false);
    		row.put('ExternalId', thisId);
    		row.put('Summmary', makeSummary());

    		rows.add(row);
    	}
    	return rows;
    }

}