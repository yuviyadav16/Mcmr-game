import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_ticbull_welcome_email(user_email, user_name):
    EMAIL_ADDRESS = os.getenv("EMAIL_USER")
    EMAIL_PASSWORD = os.getenv("EMAIL_PASS")

    msg = MIMEMultipart()
    # Yahan "Ticbull Games" naam set kiya hai
    msg['From'] = f"Ticbull Games <{EMAIL_ADDRESS}>"
    msg['To'] = user_email
    msg['Subject'] = "Welcome to the Digital Frontier | Chai & Chase"

    # Website jaisa Black & Sleek Theme
    html_content = f"""
    <html>
      <body style="font-family: 'Helvetica Neue', Arial, sans-serif; background-color: #050505; margin: 0; padding: 20px; color: #ffffff;">
        <div style="max-width: 600px; background-color: #0a0a0a; padding: 40px; border-radius: 8px; border: 1px solid #1f1f1f; margin: auto;">
          
          <!-- Logo & Header -->
          <div style="text-align: center; margin-bottom: 30px;">
            <img src="https://tumhari-website.com/ticbull.jpg" alt="Ticbull Logo" style="width: 50px; height: 50px; margin-bottom: 10px;">
            <h1 style="color: #ffffff; letter-spacing: 4px; font-weight: 300; margin: 0; font-size: 24px;">TICBULL</h1>
            <p style="color: #888888; font-size: 12px; letter-spacing: 2px; margin-top: 5px;">THE DIGITAL FRONTIER</p>
          </div>
          
          <hr style="border: 0; border-top: 1px solid #1f1f1f; margin-bottom: 30px;">
          
          <!-- Body Content -->
          <h2 style="color: #ffffff; font-weight: 400;">Welcome, {user_name}.</h2>
          <p style="font-size: 15px; line-height: 1.8; color: #b3b3b3;">
            Your account has been successfully verified. You are now officially part of the Ticbull ecosystem.
          </p>
          <p style="font-size: 15px; line-height: 1.8; color: #b3b3b3;">
            Get ready to experience <strong>Chai & Chase</strong>. Your progress, coins, and high scores are now securely synced to the cloud. You will never lose your data.
          </p>
          
          <!-- Action Button -->
          <div style="text-align: center; margin: 40px 0;">
            <a href="https://ticbull.in" style="background-color: #ffffff; color: #000000; padding: 14px 32px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; letter-spacing: 1.5px;">EXPLORE NOW &rarr;</a>
          </div>
          
          <!-- Footer -->
          <hr style="border: 0; border-top: 1px solid #1f1f1f; margin-top: 40px; margin-bottom: 20px;">
          <div style="text-align: center;">
            <p style="font-size: 12px; color: #666666; margin: 5px 0;">
              POWERED BY <strong style="color: #ffffff;">TICBULL</strong>
            </p>
            <p style="font-size: 12px; color: #444444; margin: 5px 0;">
              <a href="https://ticbull.in" style="color: #888888; text-decoration: none;">www.ticbull.in</a>
            </p>
          </div>
          
        </div>
      </body>
    </html>
    """
    
    msg.attach(MIMEText(html_content, 'html'))

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        server.send_message(msg)
        server.quit()
        print(f"✅ VIP Welcome Email sent to {user_email}")
    except Exception as e:
        print(f"❌ Error sending email: {e}")
