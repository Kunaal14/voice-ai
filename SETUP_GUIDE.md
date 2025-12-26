# Setup Guide for Voice AI Builders

This guide will help you set up your own Voice AI landing page using this template.

## 🔐 Step 1: Environment Variables Setup

### Create `.env.local` File

Copy the example file and fill in your values:

```bash
cp .env.example .env.local
```

### Required Environment Variables

#### 1. Gemini API Key (Required)
```env
GEMINI_API_KEY=your_actual_gemini_api_key_here
```
- Get your key from: https://aistudio.google.com/apikey
- **Required for**: Voice agent functionality

#### 2. Form Webhook URL (Required)
```env
FORM_WEBHOOK_URL=https://your-webhook-url.com/webhook/landing-page-form
```
- **Required for**: Contact form submissions
- **Expected payload**: 
  ```json
  {
    "name": "Company Name",
    "email": "email@example.com",
    "website": "https://example.com",
    "message": "User message",
    "source": "Landing Page Form",
    "timestamp": "2025-01-15T10:00:00.000Z"
  }
  ```

#### 3. Transcript Webhook URL (Required)
```env
TRANSCRIPT_WEBHOOK_URL=https://your-webhook-url.com/webhook/landing-page
```
- **Required for**: Saving voice conversation transcripts
- **Expected payload**:
  ```json
  {
    "session_id": "tigest_demo_1234567890",
    "lead_data": {
      "name": "John Doe",
      "email": "john@example.com",
      "business_nature": "Dental Clinic"
    },
    "full_transcript": [...],
    "duration_seconds": 120,
    "audio_file": "base64_encoded_audio"
  }
  ```

#### 4. Calendar Availability URL (Optional)
```env
CALENDAR_AVAILABILITY_URL=https://your-webhook-url.com/webhook/calendar-availability
```
- **Optional**: Only needed if you want scheduling functionality
- **Receives**:
  ```json
  {
    "date": "2025-01-15" (optional),
    "duration_minutes": 30 (optional),
    "session_id": "tigest_demo_1234567890"
  }
  ```
- **Should return**:
  ```json
  {
    "available_slots": [
      "2025-01-15T10:00:00",
      "2025-01-15T14:00:00",
      "2025-01-16T09:00:00"
    ],
    "message": "Here are the available time slots."
  }
  ```

## 🛠️ Step 2: Webhook Implementation

### Option A: Using n8n (Recommended)

1. Create a new workflow in n8n
2. Add a Webhook trigger node
3. Configure the webhook path (e.g., `/webhook/landing-page-form`)
4. Process the incoming data (save to CRM, send email, etc.)
5. Copy the webhook URL to your `.env.local`

### Option B: Using Make.com

1. Create a new scenario
2. Add a Webhook module
3. Configure the webhook
4. Add processing modules (CRM, email, etc.)
5. Copy the webhook URL to your `.env.local`

### Option C: Custom Backend

Create your own endpoint that accepts POST requests:

```javascript
// Example Express.js endpoint
app.post('/webhook/landing-page-form', (req, res) => {
  const { name, email, website, message } = req.body;
  // Process the data (save to database, send email, etc.)
  res.json({ success: true });
});
```

## 🎨 Step 3: Customize Your Landing Page

### Update Branding

1. **Company Name & Logo**
   - Edit `App.tsx` - Search for "Tigest" and replace with your brand
   - Update the `TigestLogo` component or replace with your logo

2. **Colors & Styling**
   - Primary color: Indigo (`#6366f1`) - Search and replace throughout
   - Edit `index.html` for global styles

3. **Social Links**
   - Update footer links in `App.tsx` (LinkedIn, YouTube, etc.)

4. **Content**
   - Update hero text, features, testimonials in `App.tsx`
   - Modify ROI calculator labels in `components/ROICalculator.tsx`

### Customize Voice Agent

1. **AI Persona**
   - Edit `SYSTEM_INSTRUCTION` in `components/VoiceAgent.tsx`
   - Change the AI's name, personality, and behavior

2. **Tool Calls**
   - Add custom tools in the `tools` array
   - Implement handlers in the `onmessage` callback

## 🚀 Step 4: Test Your Setup

1. **Start the dev server**:
   ```bash
   npm run dev
   ```

2. **Test the contact form**:
   - Fill out and submit the form
   - Check your webhook receives the data

3. **Test the voice agent**:
   - Click the voice agent button
   - Have a conversation
   - Verify transcript is sent to your webhook

4. **Test calendar availability** (if configured):
   - Ask: "What time slots are available?"
   - Verify your webhook is called and returns slots

## 📦 Step 5: Deploy

### Deploy to Vercel

1. Push your code to GitHub
2. Import project in Vercel
3. Add environment variables in Vercel dashboard:
   - `GEMINI_API_KEY`
   - `FORM_WEBHOOK_URL`
   - `TRANSCRIPT_WEBHOOK_URL`
   - `CALENDAR_AVAILABILITY_URL` (if using)
4. Deploy!

### Deploy to Netlify

1. Push your code to GitHub
2. Import project in Netlify
3. Add environment variables in Netlify dashboard
4. Deploy!

## ✅ Checklist Before Making Public

- [ ] All hardcoded URLs removed (using env vars)
- [ ] `.env.local` is in `.gitignore`
- [ ] `.env.example` exists with placeholder values
- [ ] README.md has setup instructions
- [ ] No API keys or secrets in code
- [ ] Test all functionality with your own webhooks
- [ ] Update branding to your company (or keep generic)

## 🔒 Security Best Practices

1. **Never commit `.env.local`** - It's already in `.gitignore`
2. **Use different webhook URLs for dev/prod**
3. **Rotate API keys regularly**
4. **Use HTTPS for all webhook URLs**
5. **Validate webhook requests** (add authentication if needed)

## 🆘 Troubleshooting

### Voice agent not working?
- Check `GEMINI_API_KEY` is set correctly
- Verify API key is valid and has credits
- Check browser console for errors

### Form submissions not working?
- Verify `FORM_WEBHOOK_URL` is set
- Test webhook URL directly with curl/Postman
- Check webhook logs for incoming requests

### Calendar availability not working?
- Ensure `CALENDAR_AVAILABILITY_URL` is set
- Verify webhook returns correct JSON format
- Check browser console for errors

## 📚 Additional Resources

- [Google Gemini API Docs](https://ai.google.dev/docs)
- [Vite Documentation](https://vitejs.dev/)
- [React Documentation](https://react.dev/)

---

**Need help?** Open an issue on GitHub or reach out to the community!

