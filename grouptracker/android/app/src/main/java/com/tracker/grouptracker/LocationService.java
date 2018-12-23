package com.tracker.grouptracker;

import android.content.Intent;
import android.app.Service;
import android.content.Context;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.location.LocationManager;
import android.location.LocationListener;
import android.os.Bundle;
import android.location.Location;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.auth.FirebaseUser;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;



public class LocationService extends Service {

    public LocationService(Context applicationContext) {
            super();
    }

    public LocationService(){}

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);

        // Acquire a reference to the system Location Manager
        LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
    
        // Define a listener that responds to location updates
        LocationListener locationListener = new LocationListener() {
            int locationChanges = 0;

            public void onLocationChanged(Location location) {

                FirebaseAuth auth = FirebaseAuth.getInstance();
                FirebaseUser currentUser = auth.getCurrentUser();
                DatabaseReference usersRef = FirebaseDatabase.getInstance().getReference().child("users");
                
                if (currentUser != null){
                    Date currentDate = new Date();
                    DateFormat dateFormatter = new SimpleDateFormat("dd-MM-yy");
                    DateFormat timeFormatter = new SimpleDateFormat("HH:mm");

                    Map newLocData = new HashMap<>();
                    newLocData.put("latitude", location.getLatitude());
                    newLocData.put("longitude", location.getLongitude());
                    newLocData.put("updated", dateFormatter.format(currentDate) 
                    + " " + timeFormatter.format(currentDate));

                    usersRef.child(currentUser.getUid()).child("location").setValue(newLocData);
                }
            }

            public void onStatusChanged(String provider, int status, Bundle extras) {}

            public void onProviderEnabled(String provider) {}

            public void onProviderDisabled(String provider) {}
        };

        // Register the listener with the Location Manager to receive location updates
        locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, locationListener);

        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}