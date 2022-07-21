const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const wordOfTheDaySchema = new Schema({
    wordOfTheDay:{type: Schema.Types.Mixed},
    wordOfTheDayId:{type: String},
    allWords:{type: Array, default: []},
    previousWordOfTheDays:{type: Array, default: []},
},{timestamps:true});

const WordOfTheDay = mongoose.model('WordOfTheDay', wordOfTheDaySchema);
module.exports = WordOfTheDay;
