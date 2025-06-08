# **Alertmanager Email Configuration with Gmail SMTP**

Below is a detailed guide on setting up **Alertmanager to send email alerts via Gmail SMTP**, including security considerations and a sample configuration.

---

## **1. Gmail SMTP Setup for Alertmanager**
### **Prerequisites**
- A **Gmail account** (or Google Workspace account).
- **Less Secure Apps (LSA) access** (if using a personal Gmail account) **OR** an **App Password** (if using 2FA).
- **SMTP Server Details**:
  - **Host**: `smtp.gmail.com`
  - **Port**: `587` (TLS) or `465` (SSL)
  - **Username**: Your full Gmail address (e.g., `youremail@gmail.com`).
  - **Password**: Your Gmail password (if LSA is enabled) **OR** an **App Password** (if 2FA is enabled).

---

### **2. Generating an App Password (If Using 2FA)**
Since Gmail no longer supports "Less Secure Apps," you must use an **App Password** if 2FA is enabled:
1. Go to **[Google Account Security](https://myaccount.google.com/security)**.
2. Enable **2-Step Verification** (if not already enabled).
3. Under **App Passwords**, generate a new password for **"Mail"** on **"Other (Custom Name)"** (e.g., "Alertmanager").
4. **Copy the generated 16-digit password** (this will be used in the Alertmanager config).

---

### **3. Alertmanager Configuration (`alertmanager.yml`)**
```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'  # TLS port
  smtp_from: 'youremail@gmail.com'
  smtp_auth_username: 'youremail@gmail.com'
  smtp_auth_password: 'your-app-password-or-gmail-password'  # Use App Password if 2FA is enabled
  smtp_require_tls: true  # Enforce TLS

route:
  receiver: 'email-notifications'
  group_by: [alertname, severity]
  group_wait: 10s
  group_interval: 5m
  repeat_interval: 3h

receivers:
- name: 'email-notifications'
  email_configs:
  - to: 'recipient@example.com'
    send_resolved: true  # Notify when alert is resolved
    headers:
      subject: 'Alert: {{ .CommonLabels.alertname }} ({{ .CommonLabels.severity }})'
    html: |
      <h2>Alert Details</h2>
      <p><strong>Alert:</strong> {{ .CommonLabels.alertname }}</p>
      <p><strong>Severity:</strong> {{ .CommonLabels.severity }}</p>
      <p><strong>Instance:</strong> {{ .CommonLabels.instance }}</p>
      <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
      <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
      <hr>
      <p><a href="http://prometheus.example.com/graph?g0.expr={{ urlquery .GroupLabels }}">View in Prometheus</a></p>
```

---

### **4. Key Configuration Details**
| Parameter | Description |
|-----------|-------------|
| `smtp_smarthost` | Gmail SMTP server (`smtp.gmail.com:587` for TLS). |
| `smtp_from` | Sender email (must match `smtp_auth_username`). |
| `smtp_auth_password` | **Gmail password** (if LSA enabled) **OR** **App Password** (if 2FA enabled). |
| `smtp_require_tls` | Ensures encrypted communication (mandatory for Gmail). |
| `send_resolved` | Sends a follow-up email when the alert is resolved. |
| `headers.subject` | Customizes the email subject. |
| `html` | Custom HTML template for rich email alerts. |

---

### **5. Testing the Configuration**
1. **Start Alertmanager**:
   ```sh
   ./alertmanager --config.file=alertmanager.yml
   ```
2. **Trigger a Test Alert**:
   - Modify a Prometheus alert rule to force a `firing` state.
   - Check your inbox (and spam folder) for the test alert.

---

### **6. Troubleshooting**
| Issue | Solution |
|-------|----------|
| **Authentication Failed** | Ensure `smtp_auth_password` is correct (App Password if 2FA is enabled). |
| **Connection Refused** | Verify firewall rules allow outbound traffic on port `587`. |
| **Emails Marked as Spam** | Use a custom `from` domain (Google Workspace) or whitelist the sender. |
| **TLS Handshake Error** | Ensure `smtp_require_tls: true` is set. |

---

### **7. Security Considerations**
- **Avoid using personal Gmail passwords** (use App Passwords instead).
- **Consider a dedicated SMTP relay** (e.g., **SendGrid, Mailgun**) for production.
- **Monitor Alertmanager logs** for failed email deliveries:
  ```sh
  journalctl -u alertmanager -f
  ```


