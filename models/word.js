const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const wordSchema = new Schema({
    word:{type:String, required:true},
    meaning:{type:String, required:true},
    type:{type:String, required:true},
    usage:{type:String, required:true},
},{timestamps:true});

const Word = mongoose.model('Word', wordSchema);
module.exports = Word;