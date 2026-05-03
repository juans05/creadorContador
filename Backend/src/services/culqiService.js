const axios = require('axios');

const culqiApi = axios.create({
  baseURL: 'https://api.culqi.com/v2',
  headers: {
    'Authorization': `Bearer ${process.env.CULQI_PRIVATE_KEY}`,
    'Content-Type': 'application/json'
  }
});

exports.createCharge = async ({ amount, currency_code, email, source_id, description }) => {
  try {
    const response = await culqiApi.post('/charges', {
      amount,
      currency_code,
      email,
      source_id,
      description
    });
    return response.data;
  } catch (error) {
    console.error('Culqi error:', error.response?.data || error.message);
    throw error;
  }
};

exports.createTransfer = async ({ amount, destination_id, description }) => {
  try {
    const response = await culqiApi.post('/transfers', {
      amount,
      currency_code: 'PEN',
      destination_id,
      description
    });
    return response.data;
  } catch (error) {
    console.error('Culqi Transfer error:', error.response?.data || error.message);
    throw error;
  }
};
