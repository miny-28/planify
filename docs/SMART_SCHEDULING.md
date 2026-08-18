                                                         smart planner logic 

1.overview :

the purpose is the organize user tasks into a realistic schedule based on :

task priority
deadlines
available time
task difficulty
user preferences
scheduling constraints
the engine should generate a schedule that helps the user complete important task before their deadlines while avoiding unrealistic workloads.

2.core data models :

2.1 task

Each task represents apiece of work that user needs to complete
عندنا تاسك الشخص حابب يخلصها
task contains:
id : رقم مميز لكل تاسك
title اسم مميز لكل تاسك :
description :تفاصيل وصف اختياريه عن التاسك بتاعتنا
estimatedDuration:الوقت ال مفروض نكون التاسك خلصت (يكون قبل ال ديد لاين )
priority : لو شخص عايز يبدا بتاسك معينه او شايف ان ليها اولويه  (اختياريه )
difficulty :مستوي صعوبه التاسك بنسبه لشخص
status :completed or in progress or not started
created at :وقت وتاريخ انشاء التاسك
completed at :وقت وتاريخ انتهاء التاسك
category :work or study or personal

2.2 schedule slot

schedule slot represents a period of time assigned to a specific task
ده ترتيب الجدول (تخصيص وقت محدد لتاسك معينه )

it contains :
task ID: ID of the assigned task
start time :start of the scheduled period // من امتي
end time : end of the scheduled period // لحد امتي
duration : length of scheduled period // المده قد ايه

2.3 user availability

user availability represent the periods during which the user is available

ده عباره عن الأوقات ال يوزر شايف نفسه فيها فاضي فا الجدول يتعمل علي أساس الأوقات ال فاضيه ويتحط فيها تاسك

it contains :
date : the date of availability // اليوم والوقت الفاضي
start time :beginning of available time // بدايه الوقت
end time :end of available time // نهايه الوقت
is available : whether the period can be used for scheduling // هل الفتره دي هتبقي فيها تاسك ولا غير متوفره


2.4 task priority factors

the scheduling engine should consider multiple factors when calculating task priority

بعد ما اليوزر بيحط كل المطلوب الجدول لازم يتحط بناءا علي أولويات منها

priority factors :
user defined priority // الاولويه الاختياريه ال اليوزر حددها
task difficulty // صعوبه التاسك
estimated duration // الوقت المتوقع لانجاز التاسك
time Pressure // بيقيس هل الوقت متاح فعليا لليوزر قبل الديد لاين كافي لانجاز تاسك مقارنه بالمده المطلوبه
task status is used to determine whether a task should be included in scheduling // هي كومبليت ولا لا

لازم التاسك ال ديدلاين بتاعها قريب المفروض تحصل علي اولويه اعلي في الجدول ولو الوقت متاح قليل  فا التاسكات المهمه لازم تخلص او تكون في الخطه الأول قبل ال تاسك ال اقلل اهميه

2.5 scheduling constraints

the scheduling engine must follow these constraints : في حاجات مينفعش تحصل في الجدول بتاعنا زي

task cannot be scheduled after its deadline // لازم التاسك تكون قبل مش بعد الديد لاين
task cannot be scheduled during unavailable time  // لازم التاسك تكون في المواعيد الفاضيه
two tasks cannot occupy its the same time period // مينفعش يكون في تاسكين في نفس الوقت
completed tasks must not be scheduled again  // التاسك ال خلصت مينفعش تتحط في الجدول تاني
the generated schedule should avoid excessive continuous workload  // مينفعش الجدول يكون مليان بشكل مرهق
A task should not exceed its estimated duration unless necessary  // المهمه مينفعش تاخد اكتر من وقتها غير في الضروره
tasks with urgent deadlines should receive priority // التاسك ال ديد لاين بتاعها قريب لازم تاخد أولوية
the schedule should be regenerated when important task information changes // الجدول لازم يتعاد ترتيبه لما يحصل تغير في الداتا

2.6 priority calcu

each task receives a calcu priority score

the score is based on the following factors :
Each factor produces a score from 0 to 100.
deadline urgency // 40%
user priority //30%
difficulty  //15%
duration //10%
Time Pressure   //5%  يعني لو حته الديد لاين بعيد بس المده كبيره تاخد التاسك بيونتس علشان هي محتاجه وقت اكبر
Priority Score =
(Deadline Score × 0.40)
+ (User Priority Score × 0.30)
+ (Difficulty Score × 0.15)
+ (Duration Score × 0.10)
+ (Time Pressure Score × 0.05)

حطينا لكل عامل سكور معين يعني ووالتاسك هتجمع بين كل العوامل دي وهيكون ليها سكور التاسك ال ليها سكور اعلي هتكون اهم انها تتعمل الأول
خلينا الترتيب العوامل من الأهم الديد لاين بعدين الاولويه بنسبه لليوزر بعدين الصعوبه بعدين المده بعدين الوقت المتبقي


2.7 Schedule Generation

The scheduling process follows these steps: //

retrieve all active tasks.
filter out completed tasks
calculate the priority score for each task.
sort tasks from highest priority to lowest priority.
retrieve the user's available time slots.
assign high-priority tasks to suitable available slots.
check deadline constraints.
avoid overlapping tasks.
continue until available time is exhausted or all tasks are scheduled.
store the generated schedule.

يعني عندنا تاسكات اهم حاجه تكون حاله التاسك غير مكتمله هنحسب ال سكور بتاع الاولويه بتاعت كل تاسك موجوده هنرتب من السكور الاعلي لل اقل ونحدد الاوقات المتاحه نبدا نحط من تاسك من السكور الاعلي للاقل ونتاكد اهم حاجه ان الديد لاين مش هيتكسر ونتاكد ان مفيش اكتر من مهمه في نفس الوقت نكمل لحد ما كل التاسكات تتحط في مكان مناسب ونحفظ الجدول الناتج  المهم ان مش شرط تكون كل وقت فاضي في تاسك المهم ان جدول يكون مش صعب وقابل لتنفيذ


كمان لازم الجدول يتجدد في حالات معينه زي
The schedule should be recalculated when significant changes occur.

Examples include:

a new task is added.
a task is completed.
a task is postponed.
a deadline changes.
estimated duration changes.
user availability changes.

المفروض ان الخطه هتكون زي ما هي بس بتغير فقط الاجزاء المتأثره بالتغير  ولما تحصل ان الجدول يتجدد التاسك الكومبليت تفضل كومبليت وبرا الجدول

#edge cases :

لو مفيش وقت متاح بنسبه ليوزر :السيستم مش هيعمل اي جدول
مده المهمه كبيره  او اكبر من فتره متاحه :السيستم هيقسم المهمه ونختار نرفع الاولوليه او لا  وينبيه اليوزر ان الوقت غير كافي
مهمتين لهم نفس الاولويه :لو مهمتين لهم نفس السكور نرتبهم حسب قرب ال الديد لاين ولو ليهم نفس الديد لاين ممكن مين محتاجه وقت اكبر  
مهمه متاخره :لو الديد لاين عدي المهمه تاخد اولويه عاليه جدا ويتم تنبيه المستخدم ليها
مهام كتير جدا :لو الوقت المطلوب لكل المهام اكبر من الوقت المتاح لليوزر النظام يختار المهام  الاهم بدل ما يعمل جدول مستحيل تنفيذه


# the result :

we will have a clear plan with :
priority a ware
deadline aware
time aware
conflict free
adaptable
realistic



##  priority :

1.deadlinr urgency score :
ده اهم عامل وزنه 40%

> 7 days → 20
4–7 days → 40
2–3 days → 60
1–2 days → 80
< 24 hours → 95
Overdue → 100


2.user priority score :
ده الوزن بتاعه 30 %

high =100
medium=60
low =30


3.difficulty score:

easy =30
medium=60
hard=100

4.durarion score :
وزنه   10 %

Duration Score =
(Task Duration / Longest Active Task Duration) × 100

ex:
Task A = 2 hours
Task B = 4 hours
Task C = 8 hours

Task A = (2 / 8) × 100 = 25
Task B = (4 / 8) × 100 = 50
Task C = (8 / 8) × 100 = 100
كده المهمه الطويله هتاخد بوينس لانها محتاجه وقت اكبر

6.Time Pressure Score:
وزنه 5 %
هل الوقت المتبقي كافي مقارنة بالوقت المطلوب كفايه لتاسك

ex :
Task A
Duration = 1 hour
Time remaining = 7 days

Task B
Duration = 6 hours
Time remaining = 1 day

Required Time Ratio =
Estimated Duration / Available Time Before Deadline

the score :
less than 10% =10
10% to less than 25% =30
25% to less than 50%=50
50% to less than 75%=70
75 to less than 100%=90
100% or more =100


the logic of priority :

ex :
Task:
Math Assignment

Deadline:
2 days

User Priority:
High

Difficulty:
Hard

Duration:
4 hours

Longest active task:
8 hours

Available time before deadline:
10 hours

deadline  - 2 days =60
high =100
hard =100
duration = (4/8)*100=50
time pressure = 4/10=40% =50

Priority Score =
(60 × 0.40)
+ (100 × 0.30)
+ (100 × 0.15)
+ (50 × 0.10)
+ (50 × 0.05)
  = 24
+ 30
+ 15
+ 5
+ 2.5

= 76.5

والسكور بيتغير مع الوقت







logic :
Task
↓
Filter Completed Tasks
↓
Calculate Deadline Score
↓
Calculate User Priority Score
↓
Calculate Difficulty Score
↓
Calculate Duration Score
↓
Calculate Time Pressure Score
↓
Apply Weights
↓
Calculate Final Priority Score
↓
Sort Tasks
↓
Apply Tie-Breakers
↓
Check User Availability
↓
Check Deadline Constraints
↓
Split Tasks If Necessary
↓
Generate Schedule    








