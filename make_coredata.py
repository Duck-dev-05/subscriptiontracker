import os

d = 'Models/SubscriptionTracker.xcdatamodeld/SubscriptionTracker.xcdatamodel'
os.makedirs(d, exist_ok=True)

xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<model type="com.apple.IDECoreDataModeler.DataModel" documentVersion="1.0" lastSavedToolsVersion="1" systemVersion="11A511" minimumToolsVersion="Xcode 9.0" sourceLanguage="Swift" userDefinedModelVersionIdentifier="">
    <entity name="CDSubscription" representedClassName="CDSubscription" syncable="YES" codeGenerationType="class">
        <attribute name="id" optional="YES" attributeType="UUID" syncable="YES"/>
        <attribute name="name" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="price" optional="YES" attributeType="Double" defaultValueString="0.0" syncable="YES" usesScalarValueType="YES"/>
        <attribute name="billingCycle" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="nextBillingDate" optional="YES" attributeType="Date" syncable="YES"/>
        <attribute name="colorHex" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="category" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="icon" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="notes" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="accountName" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="currencyCode" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="isArchived" optional="NO" attributeType="Boolean" defaultValueString="NO" syncable="YES" usesScalarValueType="YES"/>
        <attribute name="paymentHistoryData" optional="YES" attributeType="Binary" syncable="YES"/>
    </entity>
</model>
"""

with open(os.path.join(d, 'contents'), 'w') as f:
    f.write(xml)

print("Created CoreData Model")
