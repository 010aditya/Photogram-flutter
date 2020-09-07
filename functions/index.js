const functions = require('firebase-functions');
const admin  = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
.document("/followers/{userId}/userFollowers/{followerId}")
.onCreate(async(snapshot,context) => {
console.log("Follower Created",snapshot.data());
const userId = context.params.userId
const followerId = context.params.followerId;

//get followed user posts
const followedUserPostRef =admin.firestore()
.collection
.doc(userId)
.collection('userPosts');

// Get following user's timeline

const timelinePostRef = admin.firestore().
collection('timeline').document(followerId).collection('timelinePosts');


// get the followed user posrs

const querySnapshot = await followedUserPostRef.get();

// add each user post to following user's timeline

querySnapshot.forEach(doc => {
if(doc.exists){
const postId = doc.id;
const postData = doc.data();
timelinePostRef.doc(postId).set(postData);

}
})

});

exports.onDeleteFollower = functions.firestore
.document("/followers/{userId}/userFollowers/{followerId}")
.onDelete(async(snapshot,context)=>{

console.log("Follower Deleted",snapshot.id);
const userId = context.params.userId
const followerId = context.params.followerId;

const timelinePostRef = admin.firestore().
collection('timeline')
.document(followerId)
.collection('timelinePosts')
.where("ownerId","==",userId);

const querySnapshot =await timelinePostRef.get();
querySnapshot.forEach(doc =>{
if(doc.exists){
doc.timelinePostRef.delete();
}
})



});

//when a post is created we want to add post to timeline of each followe of post owner
exports.onCreatePost = functions.firestore
.document('/post/{userId}/userPosts/{postId}')
.onCreate(async(snapshot,context)=>{
const postCreate = snapshot.data();
const userId = context.params.userId;
const postId = context.params.postId;

// get all followers of post owner


const userFollowRef = admin.firestore()
.collection('followers')
.document(postId)
.collection('userFollowers');


const querySnapshot = await userFollowRef.get();

querySnapshot.forEach(doc => {
	const followerId = doc.id; 

admin.firestore()
.collection('timeline')
.doc(followerId)
.collection('timelinePosts')
.doc(postId)
.set(postCreate);

});

exports.onUpdatePost = functions.firestore
                      .document('/post/{userId}/userPosts/{postId}')
                      .onUpdate(async(change,context)=> {
                      const afterChangeData = change.after.data();
                      const userId = context.params.userId;
                      const postId = context.params.postId;


                      const userFollowRef = admin.firestore()
                      .collection('followers')
                      .document(postId)
                      .collection('userFollowers');

                      const querySnapshot = await userFollowRef.get();

                      querySnapshot.forEach(doc => {
                      	const followerId = doc.id;

                      admin.firestore()
                      .collection('timeline')
                      .doc(followerId)
                      .collection('timelinePosts')
                      .doc(postId)
                      .get().then(doc => {
                      if(doc.exists){
                      doc.ref.update(afterChangeData);
                      }
                      })
                      });
                      });

                      });





exports.onDeletePost = functions.firestore
                      .document('/post/{userId}/userPosts/{postId}')
                      .onDelete(async(snapshot,context)=> {
                      const userId = context.params.userId;
                      const postId = context.params.postId;


const userFollowRef = admin.firestore()
                      .collection('followers')
                      .document(postId)
                      .collection('userFollowers');

                      const querySnapshot = await userFollowRef.get();

                      querySnapshot.forEach(doc => {
                      	const followerId = doc.id;

                      admin.firestore()
                      .collection('timeline')
                      .doc(followerId)
                      .collection('timelinePosts')
                      .doc(postId)
                      .get().then(doc => {
                      if(doc.exists){
                      doc.ref.delete();
                      }
                      })
                      });
                      });



