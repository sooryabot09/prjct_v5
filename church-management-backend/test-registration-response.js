// test-registration-response.js
// Run this to see the exact response format from registration

const http = require('http');

const testData = {
  name: 'Test User ' + Date.now(),
  email: `test${Date.now()}@example.com`,
  password: 'password123',
  phone: '9876543210',
  church_id: 1,  // Make sure this church exists!
  role_id: 1
};

const postData = JSON.stringify(testData);

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('🧪 Testing Registration Response Format\n');
console.log('📤 Sending request to: http://localhost:3000/api/auth/register');
console.log('📝 Test data:', testData);
console.log('\n' + '='.repeat(60));

const req = http.request(options, (res) => {
  console.log(`\n📥 Response Status: ${res.statusCode}`);
  console.log(`📥 Response Headers:`, res.headers);
  console.log('\n' + '='.repeat(60));
  
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('\n📦 Raw Response Body:');
    console.log(data);
    console.log('\n' + '='.repeat(60));
    
    try {
      const jsonData = JSON.parse(data);
      console.log('\n✅ Parsed JSON Response:');
      console.log(JSON.stringify(jsonData, null, 2));
      console.log('\n' + '='.repeat(60));
      
      // Validate response structure
      console.log('\n🔍 Response Validation:');
      console.log('   ✓ Has "success" field:', 'success' in jsonData);
      console.log('   ✓ success value:', jsonData.success);
      console.log('   ✓ Has "token" field:', 'token' in jsonData);
      console.log('   ✓ Has "user" field:', 'user' in jsonData);
      console.log('   ✓ Has "message" field:', 'message' in jsonData);
      
      if (jsonData.success === true) {
        console.log('\n✅ REGISTRATION SUCCESSFUL!');
        console.log('\n📋 User Details:');
        console.log('   - ID:', jsonData.user?.user_id);
        console.log('   - Name:', jsonData.user?.name);
        console.log('   - Email:', jsonData.user?.email);
        console.log('   - Church:', jsonData.user?.church_name);
        console.log('   - Role:', jsonData.user?.role);
        console.log('   - Token:', jsonData.token ? 'Present' : 'Missing');
        
        console.log('\n✅ All checks passed! Registration working correctly.');
      } else {
        console.log('\n❌ Registration failed');
        console.log('   Error:', jsonData.error);
      }
      
    } catch (e) {
      console.log('\n❌ Failed to parse JSON response');
      console.log('   Error:', e.message);
      console.log('   This means backend is not returning valid JSON!');
    }
  });
});

req.on('error', (e) => {
  console.error('\n❌ Request Error:', e.message);
  console.error('\n💡 Troubleshooting:');
  console.error('   - Is backend running? (npm run dev)');
  console.error('   - Check if port 3000 is available');
  console.error('   - Verify database connection');
});

req.write(postData);
req.end();

// Also test if backend is reachable
setTimeout(() => {
  const healthCheck = http.get('http://localhost:3000', (res) => {
    console.log('\n\n✅ Backend is reachable at http://localhost:3000');
  }).on('error', (e) => {
    console.log('\n\n❌ Cannot reach backend at http://localhost:3000');
    console.log('   Make sure to run: cd church-management-backend && npm run dev');
  });
}, 2000);