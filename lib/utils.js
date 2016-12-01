
export const queryTransform = (parameters) => {
  return parameters ? `?${Object.keys(parameters).map((k)=>`${k}=${parameters[k]}`).join('&')}`: '';
};