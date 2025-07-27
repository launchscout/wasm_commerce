export function calculateShipping({customer: {state}}) {
  if (state === 'CA') {
    return 7899;
  } else {
    return 200;
  }
}