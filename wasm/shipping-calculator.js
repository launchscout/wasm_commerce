import productSurcharge from 'product-surcharge';
export function calculateShipping({customer: {state}, lineItems}) {
  const baseCharge = state === 'CA' ? 2000 : 200;
  const productSurcharges = lineItems.reduce((sum, {product}) => sum + productSurcharge(product), 0);
  return baseCharge + productSurcharges;
}