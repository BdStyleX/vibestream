# আপনার করণীয় (Admin Panel Tasks)

কোড, রুলস, প্রাইভেসি পলিসি ও স্টোর লিস্টিং আমি লিখে দিয়েছি। নিচের কাজগুলো শুধু আপনি করতে পারবেন, কারণ এগুলোতে আপনার অ্যাকাউন্ট, পরিচয় বা পেমেন্ট লাগে। ক্রমানুসারে করুন।

## ধাপ ১ - কম্পিউটারে টুলস (একবারই)
- [ ] Flutter SDK ইনস্টল করুন (docs.flutter.dev/get-started/install)
- [ ] Android Studio ইনস্টল করুন এবং Android SDK সেট আপ করুন
- [ ] `flutter doctor` চালান, সব সবুজ টিক না আসা পর্যন্ত ঠিক করুন
- [ ] Node.js ইনস্টল করুন, তারপর `npm install -g firebase-tools` চালান

## ধাপ ২ - Firebase প্রজেক্ট (console.firebase.google.com)
- [ ] নতুন প্রজেক্ট খুলুন (নাম: VibeStream)
- [ ] Build > Authentication > Get started > **Email/Password** চালু করুন
- [ ] Build > Firestore Database > Create database (Production mode, কাছের লোকেশন)
- [ ] Build > Storage > Get started (নতুন প্রজেক্টে এর জন্য Blaze/pay-as-you-go প্ল্যান লাগতে পারে। কনসোলে যা দেখায় সেটা দেখুন। ছোট ব্যবহারে সাধারণত ফ্রি লিমিটের মধ্যেই থাকে, তবুও Budget Alert দিয়ে রাখুন)
- [ ] Firestore > Rules ট্যাবে `firestore.rules` ফাইলের লেখা পেস্ট করে Publish করুন
- [ ] Storage > Rules ট্যাবে `storage.rules` ফাইলের লেখা পেস্ট করে Publish করুন

## ধাপ ৩ - অ্যাপ জোড়া লাগানো
- [ ] প্রজেক্ট ফোল্ডারে টার্মিনাল খুলুন
- [ ] `chmod +x setup.sh && ./setup.sh com.আপনারনাম` চালান। এই নামটা অনন্য হতে হবে এবং প্রকাশের পর বদলানো যায় না
- [ ] `firebase login` দিয়ে লগইন করুন
- [ ] `dart pub global activate flutterfire_cli` তারপর `flutterfire configure` চালান। Android বেছে নিন
- [ ] ফোন USB দিয়ে লাগিয়ে (Developer options + USB debugging চালু) `flutter run` দিন
- [ ] টেস্ট করুন: সাইন-আপ, পোস্ট, ছবি, ভিডিও, লাইক, পোল, রিপোর্ট, ব্লক, লগআউট, অ্যাকাউন্ট ডিলিট
- [ ] কোনো এরর এলে পুরো মেসেজ আমাকে পাঠান, আমি ঠিক করে দেব

## ধাপ ৪ - পাবলিশের জন্য জিনিসপত্র
- [ ] **Privacy Policy হোস্ট করুন**: `PRIVACY_POLICY.md`-এর [ব্র্যাকেটগুলো] আপনার তথ্য দিয়ে পূরণ করে GitHub Pages বা Firebase Hosting-এ দিন। একটা পাবলিক লিংক লাগবে
- [ ] সাপোর্ট ইমেইল ঠিক করুন (পলিসিতে ও স্টোরে দেখানো হবে)
- [ ] **আইকন** (512x512 PNG) বানান। লোগো SVG চাইলে আমাকে বলুন, আমি বানিয়ে দেব
- [ ] **ফিচার গ্রাফিক** (1024x500) বানান
- [ ] ফোনে অ্যাপ চালিয়ে কমপক্ষে ২টি স্ক্রিনশট তুলুন (৪-৮টা ভালো)
- [ ] অ্যাপের আইকন বসাতে চাইলে `flutter_launcher_icons` প্যাকেজ ব্যবহার করুন (আমাকে বললে সেটআপ করে দেব)

## ধাপ ৫ - সাইনিং কী (হারালে আর আপডেট দেওয়া যাবে না, ব্যাকআপ রাখুন)
- [ ] `keytool -genkey -v -keystore ~/vibestream-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- [ ] পাসওয়ার্ড লিখে নিরাপদ জায়গায় রাখুন এবং `.jks` ফাইলের কপি রাখুন
- [ ] `android/key.properties` ফাইল বানান (docs.flutter.dev/deployment/android#sign-the-app দেখুন)। এটা কাউকে দেবেন না, Git-এও তুলবেন না
- [ ] `flutter build appbundle --release` চালান। ফাইলটি পাবেন `build/app/outputs/bundle/release/app-release.aab`

## ধাপ ৬ - Google Play Console (play.google.com/console)
- [ ] ডেভেলপার অ্যাকাউন্ট খুলুন (এককালীন ফি, আমার জানামতে $25, কনসোলে নিশ্চিত হোন)
- [ ] পরিচয় যাচাই করুন (সরকারি আইডি, ঠিকানা, ফোন নম্বর লাগবে)
- [ ] Create app: নাম, ভাষা, Free, App
- [ ] Store listing: `PLAY_STORE_LISTING.md` থেকে কপি-পেস্ট করুন এবং আইকন, গ্রাফিক, স্ক্রিনশট আপলোড করুন
- [ ] App content ফর্মগুলো পূরণ করুন:
  - Privacy policy লিংক
  - Data safety (কী ডেটা নেন: ইমেইল, নাম, ছবি/ভিডিও, ইউজার আইডি। `PLAY_STORE_LISTING.md`-তে উত্তর লেখা আছে)
  - Content rating প্রশ্নমালা (UGC আছে বলতে হবে)
  - Ads: নেই
  - Target audience: ১৮+ বা ১৩+ বেছে নিন (শিশুদের জন্য বেছে নেবেন না, নিয়ম অনেক কঠিন)
  - Account deletion: অ্যাপে ডিলিটের অপশন আছে, এবং ওয়েবে ডিলিটের লিংক চাইলে দিতে হবে (পলিসি পেজে ইমেইলে অনুরোধের নিয়ম লেখা আছে)
  - Test login: রিভিউয়ারের জন্য একটা টেস্ট ইমেইল/পাসওয়ার্ড বানিয়ে দিন
- [ ] **Closed testing**: নতুন পার্সোনাল অ্যাকাউন্টে প্রোডাকশনের আগে সাধারণত ১২ জন টেস্টার নিয়ে ১৪ দিন চালাতে হয়। নিয়ম বদলায়, তাই Play Console-এর বর্তমান শর্ত দেখুন। বন্ধু-পরিবারকে Gmail ইমেইলে যোগ করুন
- [ ] তারপর Production এ `.aab` আপলোড করে রিভিউয়ে পাঠান (কয়েক দিন লাগতে পারে)

## ধাপ ৭ - চালু হওয়ার পর নিয়মিত কাজ
- [ ] Firebase Firestore > `reports` কালেকশন প্রতিদিন দেখুন। আপত্তিকর পোস্ট `posts` থেকে ডিলিট করুন। Play নীতি অনুযায়ী UGC অ্যাপে মডারেশন জরুরি
- [ ] Firebase Usage ও Billing দেখুন
- [ ] ব্যবহারকারীর ইমেইলে সাড়া দিন

## এখন যা নেই (ইচ্ছা করেই বাদ)
Live Pods, Creator Vault পেমেন্ট, Following ফিড, নোটিফিকেশন। এগুলো ফেজ ২। অ্যাপে "coming soon" দেখানো আছে, নকল সংখ্যা দেখানো হচ্ছে না। পেমেন্ট যোগ করলে Google Play Billing-এর নীতি আগে দেখে নিতে হবে।

---

# iPhone-এ টেস্ট লিংক (ওয়েব ভার্সন, Mac ছাড়াই)

iPhone-এর নেটিভ অ্যাপের জন্য Mac, Xcode ও Apple Developer অ্যাকাউন্ট (বছরে $99) লাগে, তারপর TestFlight দিয়ে টেস্ট। এটা পরে করা যাবে। এখন ওয়েব ভার্সন লাইভ করলে যে কেউ লিংক খুলে iPhone Safari-তে ব্যবহার করতে পারবে।

ধাপ ১-৩ আগের মতোই (Firebase প্রজেক্ট, `setup.sh`, `flutterfire configure`)। `flutterfire configure`-এ **Web**-ও বেছে নিন। তারপর:

- [ ] Firebase Console > Build > **Hosting** > Get started
- [ ] `flutter build web --release`
- [ ] `firebase use --add` দিয়ে আপনার প্রজেক্ট বেছে নিন
- [ ] `firebase deploy` (হোস্টিং ও দুটো রুলস একসাথে ডিপ্লয় হবে)। শেষে একটা লিংক পাবেন (`https://প্রজেক্ট.web.app`), সেটাই বন্ধুদের পাঠান
- [ ] ছবি দেখা না গেলে একবার: `gsutil cors set cors.json gs://আপনার-বাকেট-নাম` (বাকেটের নাম Storage পেজে দেখা যায়। gsutil আসে Google Cloud SDK-তে)
- [ ] iPhone-এ Safari তে লিংক খুলে Share > **Add to Home Screen** দিলে অ্যাপের মতো আইকন হবে
- [ ] ভিডিও আপলোড ও ছবি লোড একবার নিজে টেস্ট করুন

পরে Mac পেলে বা ভাড়া নিলে `ios` ফোল্ডার তৈরিই আছে, ওটা দিয়ে TestFlight করা যাবে।

---

# শুধু ফোন দিয়ে লাইভ (GitHub Pages, কম্পিউটার ছাড়া)

আপনার `BdStyleX.github.io` রিপোতে অন্য অ্যাপ আছে, তাই সেটা ছুঁইনি। VibeStream যাবে **আলাদা নতুন রিপো `vibestream`-এ**। তখন লিংক হবে `https://bdstylex.github.io/vibestream/` এবং পুরনো অ্যাপগুলোর কিছুই বদলাবে না। GitHub নিজেই (Actions দিয়ে) অ্যাপ বিল্ড করে লাইভ করবে।

- [ ] GitHub-এ নতুন রিপো খুলুন: নাম `vibestream`, **Public**
- [ ] রিপোতে এই জিপের সব ফাইল তুলুন (সবচেয়ে সহজ: claude.ai > Settings > Connectors থেকে GitHub যুক্ত করে আমাকে বলুন, আমি সরাসরি পুশ করে দেব)
- [ ] Firebase Console > Project settings > Your apps > **Web (</>)** অ্যাপ যোগ করুন, যে কনফিগ দেখাবে সেটা `lib/firebase_options.dart`-এর `PASTE_...` জায়গায় বসান (কোনো সিক্রেট নয়, ওয়েব কনফিগ পাবলিক হয়)
- [ ] Firebase > Authentication > Settings > **Authorized domains**-এ `bdstylex.github.io` যোগ করুন
- [ ] GitHub রিপো > Settings > **Pages** > Source: **GitHub Actions** বেছে নিন
- [ ] Actions ট্যাবে "Deploy VibeStream web" চালু হলে ৫-১০ মিনিট অপেক্ষা করুন। সবুজ টিক এলে লিংক খুলুন
- [ ] ছবি না দেখালে Google Cloud Console > Cloud Shell খুলে: `gsutil cors set cors.json gs://বাকেট-নাম` (cors.json ফাইলটা রিপোতে আছে)
