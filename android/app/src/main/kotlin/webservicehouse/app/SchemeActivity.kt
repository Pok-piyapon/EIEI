package webservicehouse.app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class SchemeActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Get the intent that started this activity
        val receivedIntent = intent
        
        // Check if the intent has data (deep link)
        if (receivedIntent != null && receivedIntent.data != null) {
            // Create a new intent to launch the MainActivity
            val mainIntent = Intent(this, MainActivity::class.java)
            
            // Pass the deep link data to MainActivity
            mainIntent.data = receivedIntent.data
            mainIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            
            // Start MainActivity
            startActivity(mainIntent)
        }
        
        // Finish this activity
        finish()
    }
}
