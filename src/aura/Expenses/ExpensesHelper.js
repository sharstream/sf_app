({
	createExpense : function(component, expense) {
    var theExpenses = component.get("v.expenses");

    // Copy the expense to a new object
    // THIS IS A DISGUSTING, TEMPORARY HACK
    var newExpense = JSON.parse(JSON.stringify(expense));
    console.log("Expenses before 'create': " + JSON.stringify(theExpenses));
    theExpenses.push(newExpense);
    component.set("v.expenses", theExpenses);
    console.log("Expenses after 'create': " + JSON.stringify(theExpenses));
	}
})