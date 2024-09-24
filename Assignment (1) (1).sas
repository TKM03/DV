/*load existing data*/
proc import out=data datafile="/home/u63497714/sasuser.v94/Assignment/Netflix Customer Survey (Responses) Edited - Form Responses 1.csv" 
		DBMS=CSV REPLACE;
	GETNAMES=YES;
RUN;

/* check all data */
proc print data=data;
	
/* check contents of data */
proc contents data=data;


/*DATA CLEANING*/
/* drop unuseful column */
data clean_data;
	set data;
	drop Timestamp feedback;
run;

proc print data=clean_data;

/*Identify and remove missing values*/
	libname mydata "/home/u63497714";
run;

proc freq data=clean_data;
	tables _ALL_;
run;

/*  impute values. categorical with mode*/
data newdata;
	set clean_data;

	if missing(gender) then
		gender="Male";

	if missing(age) then
		age="18 - 25";

	if missing(state) then
		state="Negeri Sembilan";

	if missing(monthly_income) then
		monthly_income="RM0";

	if missing(subscription_reason) then
		subscription_reason="Have a wide variety of shows";

	if missing(subscription_plan) then
		subscription_plan="Premium";

	if missing(payment) then
		payment="Credit and Debit Cards (eg: Visa, MasterCard, American Express)";

	if missing(device) then
		device="PCs & Laptops";
		
	if missing(pref_time) then
		pref_time="Weekends";

	if missing(watch_duration) then
		watch_duration="1 to 3 hours";

	if missing(fav_genre) then
		fav_genre="Action, Adventure, Comedy";

	if missing(movie_recom) then
		movie_recom="Demon Slayer: Kimetsu no Yaiba – The Movie: Mugen Train";

	if missing(rating) then
		rating="4";

	if missing(netflix_recom) then
		netflix_recom="4";
run;


/*check if there's still any missing value*/
proc freq data=newdata;
	tables _all_;
run;

/*library of netflix data without missing values*/
libname mydata "/home/u63497714";
run;

data mydata.netflix;
	set newdata;
run;

/*Perform a chi-squared test*/
proc freq data=mydata.netflix;
   tables monthly_income * subscription_plan / chisq; 
run;

proc freq data=mydata.netflix;
   tables watch_duration * subscription_reason / chisq; 
run;

proc sql;
SELECT monthly_income, COUNT(*) AS subscription_plan_is_basic
FROM mydata.netflix
WHERE subscription_plan LIKE '%Basic%'
GROUP BY monthly_income
ORDER BY subscription_plan_is_basic DESC;
quit;

proc sql;
SELECT device, COUNT(*) AS watch_duration_more_than_10hours
FROM mydata.netflix
WHERE watch_duration LIKE '%More than 10 hours%'
GROUP BY device
ORDER BY watch_duration_more_than_10hours DESC;
quit;

proc ttest data=mydata.netflix alpha=0.15;
where watch_duration in ('8 to 10 hours', '1 to 3 hours');
class watch_duration;
var netflix_recom;
run;

proc ttest data=mydata.netflix alpha=0.15;
where subscription_reason in ('Good recommendation system', 'Affordable,  Good video quality');
var netflix_recom;
run;

proc sql;
SELECT subscription_reason, AVG(netflix_recom) AS average_netflix_recom
FROM mydata.netflix
GROUP BY subscription_reason
ORDER BY average_netflix_recom DESC;
quit;
