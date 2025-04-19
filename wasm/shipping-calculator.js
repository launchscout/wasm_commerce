export function calculateShipping({customer: {state}}) {
  if (state === "CA") {
    return 1500;
  } else {
    return 1000;
  }
}
