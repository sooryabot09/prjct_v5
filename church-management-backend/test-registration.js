// church-management-backend/test-registration.js
// Run this to test if registration endpoint works
const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testRegistration() {
  console.log('🧪 Testing Backend Registration\n');
  
  try {
    // Test 1: Get Churches
    console.log('1️⃣ Testing GET /churches...');
    const churchesResponse = await axios.get(`${BASE_URL}/churches`);
    console.log('✅ Churches loaded:', churchesResponse.data.data.length);
    
    if (churchesResponse.data.data.length === 0) {
      console.log('⚠️  No churches found! Please add churches to database.');
      return;
    }
    
    const firstChurchId = churchesResponse.data.data[0].church_id;
    console.log(`   Using church ID: ${firstChurchId}\n`);
    
    // Test 2: Register User
    console.log('2️⃣ Testing POST /auth/register...');
    const testUser = {
      name: 'Test User ' + Date.now(),
      email: `test${Date.now()}@example.com`,
      password: 'password123',
      phone: '9876543210',
      church_id: firstChurchId,
      role_id: 1
    };
    
    console.log('   Request data:', JSON.stringify(testUser, null, 2));
    
    const registerResponse = await axios.post(
      `${BASE_URL}/auth/register`,
      testUser,
      { headers: { 'Content-Type': 'application/json' } }
    );
    
    console.log('✅ Registration successful!');
    console.log('   User ID:', registerResponse.data.user.user_id);
    console.log('   Name:', registerResponse.data.user.name);
    console.log('   Email:', registerResponse.data.user.email);
    console.log('   Church:', registerResponse.data.user.church_name);
    console.log('   Token received:', registerResponse.data.token ? 'Yes' : 'No');
    
    // Test 3: Login with new user
    console.log('\n3️⃣ Testing POST /auth/login...');
    const loginResponse = await axios.post(
      `${BASE_URL}/auth/login`,
      {
        email: testUser.email,
        password: testUser.password
      },
      { headers: { 'Content-Type': 'application/json' } }
    );
    
    console.log('✅ Login successful!');
    console.log('   Token received:', loginResponse.data.token ? 'Yes' : 'No');
    
    console.log('\n✅ All tests passed! Backend is working correctly.');
    
  } catch (error) {
    console.error('\n❌ Test failed!');
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Error:', error.response.data);
    } else {
      console.error('   Error:', error.message);
    }
    console.error('\n💡 Troubleshooting:');
    console.error('   1. Make sure backend server is running: npm run dev');
    console.error('   2. Check if database has churches: SELECT * FROM churches;');
    console.error('   3. Verify database connection in .env file');
    console.error('   4. Check backend console for error details');
  }
}

// Run the test
testRegistration();