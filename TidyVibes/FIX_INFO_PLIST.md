# Fix Info.plist Crash - Manual Key Entry

Add these keys EXACTLY as shown in Xcode's Info tab:

## Keys to Add (use the dropdown, don't type manually):

1. **Privacy - Camera Usage Description**
   - Value: `TidyVibes needs camera access to photograph your items`

2. **Privacy - Microphone Usage Description**
   - Value: `TidyVibes needs microphone access for voice input`

3. **Privacy - Speech Recognition Usage Description**
   - Value: `TidyVibes uses speech recognition for voice capture`

4. **Privacy - Photo Library Usage Description**
   - Value: `TidyVibes can import photos from your library`

## How to Add in Xcode:

1. Project Navigator → Click **TidyVibes** (blue icon)
2. Select **TidyVibes** target (under TARGETS)
3. Click **Info** tab
4. Find "Custom iOS Target Properties" section
5. Hover over any row and click the **+** button
6. When you click the key field, a dropdown appears - **use the dropdown to select** the privacy keys
7. Don't type the key names manually - use the dropdown list!

## Step-by-step for First Key:

1. Click **+** button
2. Click on "Key" field
3. Start typing "camera"
4. You'll see **"Privacy - Camera Usage Description"** in dropdown
5. Select it
6. In "Value" field, paste: `TidyVibes needs camera access to photograph your items`
7. Repeat for the other 3 keys

## After Adding All Keys:

1. **Clean Build Folder**: Product → Clean Build Folder (Shift + Cmd + K)
2. **Delete app from iPhone**: Long press app icon → Remove App
3. **Rebuild**: Cmd + R
4. The crash should be fixed!

## Visual Check:

Your Info tab should show these 4 rows under Custom iOS Target Properties:
```
Privacy - Camera Usage Description          | TidyVibes needs camera access...
Privacy - Microphone Usage Description      | TidyVibes needs microphone access...
Privacy - Speech Recognition Usage Description | TidyVibes uses speech recognition...
Privacy - Photo Library Usage Description   | TidyVibes can import photos...
```
