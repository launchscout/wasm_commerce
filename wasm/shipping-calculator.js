export async function calculateShipping({customer: {address: {state}}}) {
  console.log(`State: ${state}`);
  if (state == 'CA') {
    return 1500;
  } else {
    return 500;
  }
}