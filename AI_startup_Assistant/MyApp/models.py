from django.db import models
from django.contrib.auth.models import User
# Create your models here.
class Expert_table(models.Model):
    LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    contact=models.BigIntegerField()
    qualification=models.CharField(max_length=100)
    experience=models.CharField(max_length=100)
    status=models.CharField(max_length=100)

class company_table(models.Model):
    LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)
    name= models.CharField(max_length=100)
    email= models.CharField(max_length=100)
    phone= models.BigIntegerField()
    image = models.FileField()
    bio = models.CharField(max_length=100)
    company_name=models.CharField(max_length=100)
    status=models.CharField(max_length=100)

class Users_table(models.Model):
    LOGIN = models.ForeignKey(User,on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.BigIntegerField()
    place = models.CharField(max_length=100)
    post = models.CharField(max_length=100)
    pin = models.BigIntegerField()
    qualification = models.CharField(max_length=100)  
    skills = models.CharField(max_length=100)
    interested_area = models.CharField(max_length=100)

class Complaint_table(models.Model):
    USER = models.ForeignKey(Users_table, on_delete=models.CASCADE)
    complaint = models.CharField(max_length=100)
    date = models.DateField()
    reply = models.CharField(max_length=100)

class System_feedback(models.Model):
    LOGIN = models.ForeignKey(User, on_delete=models.CASCADE)
    feedback = models.CharField(max_length=100)
    date = models.DateField()

class Notification_table(models.Model):
    notification = models.CharField(max_length=100)
    details = models.CharField(max_length=100)
    date = models.DateField()

class Startup_idea_table(models.Model):
    LOGIN = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=100)
    description = models.CharField(max_length=100)
    industry = models.CharField(max_length=100)

class legal_guide_table(models.Model):
    EXPERT = models.ForeignKey(Expert_table, on_delete=models.CASCADE)
    title = models.CharField(max_length=100)
    content = models.CharField(max_length=100)
    category = models.CharField(max_length=100)

class doubt_table(models.Model):
    USER = models.ForeignKey(Users_table, on_delete=models.Model)
    EXPERT = models.ForeignKey(Expert_table, on_delete=models.Model)
    feedback = models.CharField(max_length=100)
    reply = models.CharField(max_length=100)
    date = models.DateField()

class Feedback_table(models.Model):
    USER = models.ForeignKey(Users_table, on_delete=models.CASCADE)
    EXPERT = models.ForeignKey(Expert_table, on_delete=models.CASCADE)
    feedback = models.CharField(max_length=100)
    rating = models.CharField(max_length=100)
    date = models.DateField()

class chat_table(models.Model):
    FROM = models.ForeignKey(User, on_delete=models.CASCADE, related_name='from_id')
    TO = models.ForeignKey(User, on_delete=models.CASCADE, related_name='to_id')
    message = models.CharField(max_length=100)
    date = models.DateField()
    time=models.CharField(max_length=100)

class request_table(models.Model):
    USER = models.ForeignKey(Users_table, on_delete=models.CASCADE)
    STARTUP = models.ForeignKey(Startup_idea_table, on_delete=models.CASCADE)
    date = models.DateField()
    status = models.CharField(max_length=100)

class Request_table_company(models.Model):
    STARTUP = models.ForeignKey(Startup_idea_table, on_delete=models.CASCADE)
    company = models.ForeignKey(company_table, on_delete=models.CASCADE)
    date = models.DateField()
    status = models.CharField(max_length=100)

class Fund_table(models.Model):
    COMPANY = models.ForeignKey(company_table, on_delete=models.CASCADE)
    request= models.ForeignKey(Request_table_company, on_delete=models.CASCADE)
    amount = models.BigIntegerField()

class skill_table(models.Model):
    USER = models.ForeignKey(Users_table, on_delete=models.CASCADE)
    skill = models.CharField(max_length=100)
    date = models.DateField()

class Chatbot(models.Model):
    USER=models.ForeignKey(Users_table,on_delete=models.CASCADE)
    date=models.DateField()
    question=models.CharField(max_length=100)
    answer=models.CharField(max_length=100)

