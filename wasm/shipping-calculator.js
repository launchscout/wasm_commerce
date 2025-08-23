import productSurcharge from 'product-surcharge';
export async function calculateShipping({customer: {city, state}, lineItems}) {
  const response = await fetch(`https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/${city}?unitGroup=us&key=33LLKENY98MLPZAF3BY8AH8JS&contentType=json`);
  const {currentConditions} = await response.json();
  console.log(`conditions: ${currentConditions.conditions}`);
  if (currentConditions.conditions.toLowerCase() == 'clear') {
    return 0;
  } else {
    return 1000;
  }
}