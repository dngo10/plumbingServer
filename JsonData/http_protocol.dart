enum HTTPMETHOD{
  post,
  put,
  delete,
  get
}

Map<HTTPMETHOD, String> httpMethodMap = {
  HTTPMETHOD.delete: 'DELETE',
  HTTPMETHOD.get: 'GET',
  HTTPMETHOD.post: 'POST',
  HTTPMETHOD.put: 'PUT'
};

/// OLD
/// "client_secret": "7AE1nNd16Tj-Eb5n__DaGlSm2Y7of.S4-8"