import random
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from django.contrib.auth import authenticate, login
from django.contrib.auth.hashers import make_password
from django.core.files.storage import FileSystemStorage
from django.shortcuts import render, redirect
from datetime import datetime
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import make_password, check_password
from django.contrib import messages

from  django.contrib.auth.models import Group,User
from django.http import JsonResponse
from MyApp.models import*

import json
import google.generativeai as genai

# Create your views here.

def login_get(request):
    return render(request,'loginindex.html')


from django.contrib import messages
from django.contrib.auth import authenticate, login


def login_post(request):
    username = request.POST.get('username')
    password = request.POST.get('password')

    print(username)
    print(password)

    ob = authenticate(request, username=username, password=password)
    print(ob, "hhhhhhhhhhhhhhhhh")

    if ob is not None:

        if ob.groups.filter(name="admin").exists():
            login(request, ob)
            return redirect('/myapp/admin_home_get/')

        elif ob.groups.filter(name='expert').exists():
            a = Expert_table.objects.get(LOGIN_id=ob.id)

            if a.status == 'accepted':
                login(request, ob)
                return redirect('/myapp/expert_home_get/')
            else:
                messages.error(request, "Your account is not approved yet.")
                return redirect('/myapp/login_get/')

        else:
            messages.error(request, "Unauthorized user role.")
            return redirect('/myapp/login_get/')

    else:

        messages.error(request, "Incorrect username or password!")
        return redirect('/myapp/login_get/')


def change_password_get(request):
    return render(request,'admin1/change_password.html')


@csrf_exempt
def change_passwordpost(request):
    current_password = request.POST['current_password']
    new_password = request.POST['new_password']
    confirm_password = request.POST['confirm_password']

    f = check_password(current_password, request.user.password)
    if f:
        if new_password == confirm_password:
            user = request.user
            user.set_password(confirm_password)
            user.save()
            messages.success(request, "Password changed successfully. Please log in again.")
            return redirect('/myapp/login_get/')
        else:
            messages.error(request, "New password and confirm password do not match.")
            return redirect('/myapp/change_password_get/')
    else:
        messages.error(request, "Current password is incorrect.")
        return redirect('/myapp/change_password_get/')


def expertregister(request):
    return render(request,'expert/register_expert.html')

def expertregister_post(request):
    name=request.POST['name']
    email=request.POST['email']
    contact=request.POST['phone']
    qualification=request.POST['qualification']
    experience=request.POST['experience']
    username=request.POST['username']
    password=request.POST['password']
    user=User.objects.create(username= username,password=make_password(password), email= email, first_name=name)
    user.save()
    user.groups.add(Group.objects.get(name="expert"))

    ob=Expert_table()
    ob.LOGIN=user
    ob.name=name
    ob.email=email
    ob.contact=contact
    ob.qualification=qualification
    ob.experience=experience
    ob.status='pending'
    ob.save()
    return redirect('/myapp/login_get/')


def add_notification_get(request):
    return render(request,'admin1/add_notification.html')

def add_notification_post(request):
    Notification=request.POST['notification']
    Details=request.POST['details']

    ob=Notification_table()
    ob.notification=Notification
    ob.details=Details
    ob.date = datetime.now()
    ob.save()
    return redirect('/myapp/view_notification_get/')


#####
def add_startupidea_get(request):
    return render(request,'admin1/add_startup_idea.html')

def add_startupidea_post(request):
    Title=request.POST['title']
    Description=request.POST['description']
    Industry=request.POST['industry']

    ob=Startup_idea_table()
    ob.LOGIN = request.user
    ob.title=Title
    ob.description=Description
    ob.industry=Industry
    ob.save()
    return redirect('/myapp/view_startup_gets/')

####


def admin_home_get(request):
    return render(request,'admin1/admin_index.html')


#####


def change_password_get_expert(request):
    return render(request,'expert/change_password.html')

def change_passwordpost_expert(request):
    current_password = request.POST['current_password']
    new_password = request.POST['new_password']
    confirm_password = request.POST['confirm_password']

    f = check_password(current_password, request.user.password)
    if f:
        if new_password == confirm_password:
            user = request.user
            user.set_password(confirm_password)
            user.save()
            messages.success(request, "Password changed successfully. Please log in again.")
            return redirect('/myapp/login_get/')
        else:
            messages.error(request, "New password and confirm password do not match.")
            return redirect('/myapp/change_password_get/')
    else:
        messages.error(request, "Current password is incorrect.")
        return redirect('/myapp/change_password_get/')



#####
def edit_startup_idea_get(request,id):
    request.session['id'] = id
    a = Startup_idea_table.objects.get(id=id)
    return render(request,'admin1/edit_startup_idea.html',{'data':a})

def edit_startup_idea_post(request):
    Title=request.POST['title']
    Description=request.POST['description']
    Industry=request.POST['industry']

    ob = Startup_idea_table.objects.get(id=request.session['id'])
    ob.title = Title
    ob.description = Description
    ob.industry = Industry
    ob.save()
    return redirect('/myapp/view_startup_gets/')

def delete_startup(request,id):
    a=Startup_idea_table.objects.get(id=id)
    a.delete()
    return redirect('/myapp/view_startup_gets/')


#######


def expert_get(request):
    a = Expert_table.objects.all()
    return render(request, 'admin1/verify expert.html',{'data':a})


######company#####


def company_get(request):
    a=company_table.objects.all()
    return render(request, 'admin1/company.html', {'data':a})

def acceptcompany(request,id):
    a=company_table.objects.filter(id=id).update(status='accepted')
    messages.success(request,'company Approved')
    return redirect('/myapp/company_get/')

def rejectcompany(request,id):
    a=company_table.objects.filter(id=id).update(status='rejected')
    messages.success(request, 'company Rejected')
    return redirect('/myapp/company_get/')

def blockcompany(request,id):
    a=company_table.objects.filter(id=id).update(status='blocked')
    messages.success(request,'company account blocked')
    return redirect('/myapp/company_get/')

def unblockcompany(request,id):
    a=company_table.objects.filter(id=id).update(status='unblocked')
    messages.success(request,'company account unblocked')
    return redirect('/myapp/company_get/')


######

def user_detail_get(request):
    a=Users_table.objects.all()
    return render(request,'admin1/user_details.html',{'data':a})

######

def sendreplys(request,id):
    request.session['rid']=id
    a=Complaint_table.objects.get(id=id)
    return render(request,'admin1/send_reply.html')

def sendreplyspost(request):
    complaint=request.POST["reply"]
    ob=Complaint_table.objects.get(id=request.session['rid'])
    ob.reply=complaint
    ob.save()
    return redirect('/myapp/view_complaint_get/')

def sendreply_doubt(request,id):
    request.session['rid']=id
    a=doubt_table.objects.get(id=id)
    return render(request,'expert/doubt_reply.html')

def sendreplyspost_doubt(request):
    feedback=request.POST["reply"]
    ob=doubt_table.objects.get(id=request.session['rid'])
    ob.reply=feedback
    ob.save()
    return redirect('/myapp/view_doubt_get/')


######


def view_complaint_get(request):
    ob=Complaint_table.objects.all()
    return render(request,'admin1/view_complaint.html',{'data':ob})

def view_notification_get(request):
    a=Notification_table.objects.all()
    return render(request,'admin1/view_notification.html',{'data':a})

def delete_notification(request,id):
    a=Notification_table.objects.get(id=id)
    a.delete()
    return redirect('/myapp/view_notification_get/')

def view_startup_gets(request):
    a = Startup_idea_table.objects.filter(LOGIN__id=request.user.id)
    return render(request, 'admin1/view_startupideas.html', {'data': a})


def view_startup_all(request):
    a = Startup_idea_table.objects.exclude(LOGIN_id=request.user.id)
    print("aaaaaa")
    l = []

    for i in a:
        user = i.LOGIN
        groups = user.groups.all()

        for g in groups:
            print("Group:", g.name)

            if g.name == "expert":
                c = Expert_table.objects.get(LOGIN_id=i.LOGIN)
                l.append({
                    "id": i.id,
                    "type": "expert",
                    "name": c.name,
                    "title":i.title,
                    "description":i.description,
                    "industry":i.industry,
                })

            elif g.name == "user":
                c = Users_table.objects.get(LOGIN_id=i.LOGIN)
                l.append({
                    "id": i.id,
                    "type": "user",
                    "name": c.name,
                    "title":i.title,
                    "description":i.description,
                    "industry":i.industry,
                })

            # elif g.name == "admin":
            #     l.append({
            #         "id": i.id,
            #         "type": "admin",
            #         "name": user.username,
            #         "username": user.username,
            #         "title": i.title,
            #         "description": i.description,
            #         "industry": i.industry,
            #
            #     })

    return render(request, 'admin1/view_startup_idea_all.html', {'data': l})


def view_system_feedback_get(request):
    a=System_feedback.objects.all()
    print("aaaaaa")
    l = []

    for i in a:
        user = i.LOGIN
        groups = user.groups.all()

        for g in groups:
            print("Group:", g.name)

            if g.name == "company":
                c = company_table.objects.get(LOGIN_id=i.LOGIN)
                l.append({
                    "id": i.id,
                    "type": "company",
                    "name": c.name,
                    "feedback": i.feedback,
                    "date": i.date,
                })

            elif g.name == "user":
                c = Users_table.objects.get(LOGIN_id=i.LOGIN)
                l.append({
                    "id": i.id,
                    "type": "user",
                    "name": c.name,
                    "feedback": i.feedback,
                    "date": i.date,
                })


    return render(request,'admin1/view_system_feedback.html',{'data':l})


# ============================== expert ================

def acceptexpert(request,id):
    a=Expert_table.objects.filter(id=id).update(status='accepted')
    messages.success(request,'Expert Approved')
    return redirect('/myapp/expert_get/')

def rejectexpert(request,id):
    a=Expert_table.objects.filter(id=id).update(status='rejected')
    messages.success(request, 'Expert Rejected')
    return redirect('/myapp/expert_get/')

def blockexpert(request,id):
    a=Expert_table.objects.filter(id=id).update(status='block')
    messages.success(request,'expert account blocked')
    return redirect('/myapp/expert_get/')

def unblockexpert(request,id):
    a=Expert_table.objects.filter(id=id).update(status='unblock')
    messages.success(request,'Expert account unblocked')
    return redirect('/myapp/expert_get/')

def expert_change_password_get(request):
    return render(request,'expert/change_password.html')

def details_get(request):
    return render(request, 'expert/Add_legal_guide.html')

def doubt_reply_get(request):
    return render(request,'expert/doubt_reply.html')

def manage_legal_guide_get(request):
    a=legal_guide_table.objects.filter(EXPERT__LOGIN_id=request.user.id)
    return render(request,'expert/manage_legal_guide.html',{'data':a})

def add_legal_guide(request):
    return render(request,'expert/Add_legal_guide.html')

def add_legal_guide_Post(request):
    title=request.POST['title']
    content=request.POST['content']
    category=request.POST['category']
    ob=legal_guide_table()
    ob.EXPERT = Expert_table.objects.get(LOGIN_id=request.user.id)
    ob.title=title
    ob.content=content
    ob.category=category
    ob.save()
    return redirect('/myapp/manage_legal_guide_get/')

def delete_legal_guide(request,id):
    ob=legal_guide_table.objects.get(id=id)
    ob.delete()
    return redirect('/myapp/manage_legal_guide_get/')

def suggestion_add_get(request):
    return render(request,'expert/suggestion_add.html')

def update_profile_get(request):
    a=Expert_table.objects.get(LOGIN_id=request.user.id)
    return render(request,'expert/update_profile.html',{'data':a})

def Updateprofile_post(request):
    if request.method == "POST":
        name = request.POST['name']
        email = request.POST['email']
        contact = request.POST['phone']
        qualification = request.POST['qualification']
        experience = request.POST['experience']


        ob = Expert_table.objects.get(LOGIN_id=request.user.id)
        ob.name = name
        ob.email = email
        ob.contact = contact
        ob.qualification = qualification
        ob.experience = experience
        ob.status = 'pending'
        ob.save()
        return redirect('/myapp/view_profile_get/')

def view_doubt_get(request):
    a=doubt_table.objects.filter(EXPERT__LOGIN_id=request.user.id)
    return render(request,'expert/view_doubt.html',{'data':a})


def expert_view_notification_get(request):
    a=Notification_table.objects.all()
    return render(request,'expert/view_notification.html',{'data':a})

def expert_view_Request_get(request):
    a=request_table.objects.all()
    return render(request,'expert/view_request_&_verify.html',{'data':a})

def acceptrequest(request,id):
    a=request_table.objects.filter(id=id).update(status='accepted')
    messages.success(request,'request Approved')
    return redirect('/myapp/expert_view_Request_get/')

def rejectrequest(request,id):
    a=request_table.objects.filter(id=id).update(status='rejected')
    messages.success(request,'request rejected')
    return redirect('/myapp/expert_view_Request_get/')

def logout_get(request):
    return render(request,'loginindex.html')

def view_profile_get(request):
    a=Expert_table.objects.get(LOGIN__id=request.user.id)
    return render(request,'expert/view_profile.html',{'data':a})

def view_suggestion_expert(request):
    a = Startup_idea_table.objects.filter(LOGIN__id=request.user.id)
    return render(request, 'expert/view_suggestions.html', {'data': a})


def view_suggestion_get(request):
    a = Startup_idea_table.objects.exclude(LOGIN_id=request.user.id)
    print("aaaaaa")
    l = []

    for i in a:
        user = i.LOGIN
        groups = user.groups.all()

        for g in groups:
            print("Group:", g.name)

            if g.name == "expert":
                c = Expert_table.objects.get(LOGIN_id=i.LOGIN)
                l.append({
                    "id": i.id,
                    "type": "expert",
                    "name": c.name,
                    "title":i.title,
                    "description":i.description,
                    "industry":i.industry,
                })

            elif g.name == "user":
                c = Users_table.objects.get(LOGIN_id=i.LOGIN)
                l.append({
                    "id": i.id,
                    "type": "user",
                    "name": c.name,
                    "title":i.title,
                    "description":i.description,
                    "industry":i.industry,
                })

            elif g.name == "admin":
                l.append({
                    "id": i.id,
                    "type": "admin",
                    "name": user.username,
                    "username": user.username,
                    "title": i.title,
                    "description": i.description,
                    "industry": i.industry,

                })

    return render(request, 'expert/view_all_suggestion.html', {'data': l})


def add_suggestion(request):
    return render(request,'expert/suggestion_add.html')

def add_suggestion_post(request):
    Title=request.POST['title']
    Description=request.POST['description']
    Industry=request.POST['industry']


    ob=Startup_idea_table()
    ob.LOGIN = request.user
    ob.title=Title
    ob.description=Description
    ob.industry=Industry
    ob.save()
    return redirect('/myapp/view_suggestion_expert/')

def delete_suggestion(request,id):
    a=Startup_idea_table.objects.get(id=id)
    a.delete()
    return redirect('/myapp/view_suggestion_expert/')


def view_feedback_get(request):
    a=Feedback_table.objects.filter(EXPERT__LOGIN_id=request.user.id)
    return render(request,'expert/view_feedback.html',{'data':a})

def view_complaints(request):
    ob=Complaint_table.objects.all()
    return render(request,'expert/view_complaint.html',{'data':ob})

def expert_home_get(request):
    return render(request, 'expert/expert_home.html')

##############company########

def loginpost(request):
    username = request.POST['username']
    print(username)
    password = request.POST['password']
    print(password)

    u = authenticate(request, username=username, password=password)
    print(u)

    if u is not None:
        if u.groups.filter(name='company').exists():
            ob=company_table.objects.get(LOGIN__id=u.id)
            if ob.status == 'accepted':
                print('company login success')
                login(request, u)
                return JsonResponse({"type":"company","status": "ok", 'lid': request.user.id})
        elif u.groups.filter(name='user').exists():
            print('User login success')
            login(request, u)
            return JsonResponse({"type":"user","status": "ok", 'lid': request.user.id})
        else:
            return JsonResponse({"status": "no"})
    print('Authentication failed')
    return JsonResponse({"status": "no"})


def company_register(request):
    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    image = request.FILES['photo']
    bio = request.POST['bio']
    company_name = request.POST['company']
    username = request.POST['username']
    password = request.POST['password']

    lg = User.objects.create(username=username, password=make_password(password))
    lg.groups.add(Group.objects.get(name='company'))

    cobj = company_table()
    cobj.name = name
    cobj.email = email
    cobj.phone = phone
    cobj.image = image
    cobj.bio = bio
    cobj.company_name = company_name
    cobj.status = 'pending'
    cobj.LOGIN=lg
    cobj.save()
    return JsonResponse({'status': 'ok'})

def updateprofile(request):
    name = request.POST["name"]
    email=request.POST["email"]
    phone=request.POST['phone']
    bio=request.POST['bio']
    company=request.POST['company']
    lid=request.POST['lid']
    ob=company_table.objects.get(LOGIN_id=lid)

    if 'image' in request.FILES:
        image = request.FILES["image"]
        fs = FileSystemStorage()
        path = fs.save(image.name, image)
        ob.image = path
        ob.save()

    ob.name=name
    ob.email=email
    ob.phone=phone
    ob.bio=bio
    ob.company_name=company
    ob.status='pending'
    ob.save()
    return JsonResponse({"status":"ok"})

def viewprofile(request):
    lid = request.POST['lid']
    ob = company_table.objects.get(LOGIN__id=lid)
    image_url = request.build_absolute_uri(ob.image.url) if ob.image else ""
    print(image_url,"@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    return JsonResponse({
        "status": "ok",
        "name": ob.name,
        "email": ob.email,
        "phone": str(ob.phone),
        "bio": ob.bio,
        "company_name":ob.company_name,
        "image": image_url,
    })


def change_passwordpost_company(request):
    oldpassword = request.POST['oldpassword']
    newpassword = request.POST['newpassword']
    confirmpassword = request.POST['newpassword']
    lid=request.POST['lid']
    print(oldpassword, newpassword,confirmpassword,lid)
    p=User.objects.get(id=lid).password
    print(request.user)
    f = check_password(oldpassword, p)
    if f:
        user = User.objects.get(id=lid)
        user.set_password(newpassword)
        user.save()
        return JsonResponse({'status': 'ok'})
    else:
        return JsonResponse({'status': 'no'})


def view_notification(request):
    ob = Notification_table.objects.all()
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'date': str(i.date),
            'notification': i.notification,
            'details': i.details,

        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})


def view_startup(request):
    ob = Startup_idea_table.objects.exclude(LOGIN_id=1)
    mdata = []
    for i in ob:
        try:
            obu=Users_table.objects.get(LOGIN__id=i.LOGIN.id)
            data = {
                'id': i.id,
                'uname':obu.name,
                'uemail':obu.email,
                'uphone':obu.phone,
                'title': i.title,
                'description': i.description,
                'industry': i.industry,
                'LOGIN': i.LOGIN.id,
                'user': i.LOGIN.username,
            }
            mdata.append(data)
        except:
            pass
    return JsonResponse({"status": "ok", "data": mdata})


# def Placement_TrendingSkills(req):
#     # Fetch all vacancies
#     vacancies = Vacancy.objects.all()
#     inv_words=['software','associate','accountant']
#     # Containers for skills and job roles
#     skill_words = []
#     role_words = []
#
#     for v in vacancies:
#         # Combine text fields for analysis
#         text = f"{v.skills} {v.job_role}"
#
#         # Process with spaCy NLP
#         doc = nlp(text.lower())
#
#         # Extract nouns and proper nouns (skill-like words)
#         for token in doc:
#             if token.pos_ in ["NOUN", "PROPN"] and len(token.text) > 2:
#                 if token.lemma_.lower() not in inv_words:
#                     skill_words.append(token.lemma_)
#
#         # Separate role-specific words (optional)
#         role_words.append(v.job_role.lower())
#
#     # Count frequency
#     skill_freq = Counter(skill_words).most_common(5)
#     role_freq = Counter(role_words).most_common(5)
#
#     # Prepare lists for chart
#     trending_skills = [s[0].title() for s in skill_freq]
#     skill_counts = [s[1] for s in skill_freq]
#
#     trending_roles = [r[0].title() for r in role_freq]
#     role_counts = [r[1] for r in role_freq]
#
#     context = {
#         'trending_skills': zip(trending_skills, skill_counts),
#         'trending_roles': zip(trending_roles, role_counts),
#     }
#
#     return render(req, "placement/Trending.html", context)


# def view_recommendation(request):
#     ob = Startup_idea_table.objects.exclude(LOGIN_id=1)
#     mdata = []
#     for i in ob:
#         try:
#             obu=Users_table.objects.get(LOGIN__id=i.LOGIN.id)
#             data = {
#                 'id': i.id,
#                 'uname':obu.name,
#                 'uemail':obu.email,
#                 'uphone':obu.phone,
#                 'title': i.title,
#                 'description': i.description,
#                 'industry': i.industry,
#                 'LOGIN': i.LOGIN.id,
#                 'user': i.LOGIN.username,
#             }
#             mdata.append(data)
#         except:
#             pass
#     return JsonResponse({"status": "ok", "data": mdata})


from collections import Counter
from django.http import JsonResponse
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def NLP_Startup_Recommendation(request):
    lid=request.POST['lid']
    ideas = list(Startup_idea_table.objects.exclude(LOGIN_id=lid).order_by('-id'))
    print(ideas,"ideas")

    if len(ideas) < 2:
        return JsonResponse({'status':'ok','data':[]})

    # Map descriptions to idea list
    desc_counter = Counter([i.description for i in ideas])
    # Most common description (concept)
    most_common_desc = desc_counter.most_common(1)[0][0]

    # Find index of a startup with that description
    latest_index = next(i for i, idea in enumerate(ideas) if idea.description == most_common_desc)

    # Build documents for TF-IDF
    documents = [f"{i.title} {i.description} {i.industry}".lower() for i in ideas]

    print(documents,"documentd")

    vectorizer = TfidfVectorizer(stop_words='english', ngram_range=(1,2))
    tfidf_matrix = vectorizer.fit_transform(documents)
    similarity_matrix = cosine_similarity(tfidf_matrix)

    # Similarity scores for the most common concept
    similarity_scores = list(enumerate(similarity_matrix[latest_index]))

    # Remove self similarity
    similarity_scores = [s for s in similarity_scores if s[0] != latest_index]

    # Sort by similarity DESC
    similarity_scores.sort(key=lambda x: x[1], reverse=True)

    top_indices = [i[0] for i in similarity_scores[:10]]

    mdata = []
    for idx in top_indices:
        idea = ideas[idx]
        try:
            user = Users_table.objects.get(LOGIN=idea.LOGIN)
            mdata.append({
                'id': str(idea.id),
                'title': idea.title,
                'description': idea.description,
                'industry': idea.industry,
                'uname': user.name,
                'uemail': user.email,
                'uphone': str(user.phone)
            })
        except:
            pass

    return JsonResponse({'status':'ok','data':mdata})




def sendfeedback_post(request):
    lid=request.POST['lid']
    feedback = request.POST['feedback']

    k=System_feedback()
    k.feedback=feedback
    k.LOGIN =User.objects.get(id=lid)
    k.date=datetime.today()
    k.save()

    return JsonResponse({'status': 'ok'})

from datetime import datetime
from django.http import JsonResponse
from .models import *

def sendrequest_company(request):
    print(request.POST)

    lid = request.POST['lid']
    sid = request.POST['sid']

    ob = Request_table_company.objects.filter(STARTUP_id=sid,company__LOGIN_id=lid).first()

    if ob is not None:
        return JsonResponse({'status': 'No'})


    cobj = Request_table_company()
    cobj.date = datetime.today()
    cobj.status = "pending"
    cobj.STARTUP = Startup_idea_table.objects.get(id=sid)
    cobj.company = company_table.objects.get(LOGIN__id=lid)
    cobj.save()

    return JsonResponse({'status': 'ok', 'lid': lid})


#########user##########

def user_register(request):
    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    place = request.POST['place']
    pin = request.POST['pin']
    post = request.POST['post']
    qualification = request.POST['qualification']
    skills = request.POST['skills']
    interested_area = request.POST['interested_area']
    username = request.POST['username']
    password = request.POST['password']

    lg = User.objects.create(username=username, password=make_password(password))
    lg.groups.add(Group.objects.get(name='User'))

    cobj = Users_table()
    cobj.name = name
    cobj.email = email
    cobj.phone = phone
    cobj.place = place
    cobj.post = post
    cobj.pin = pin
    cobj.qualification =qualification
    cobj.skills = skills
    cobj.interested_area = interested_area

    cobj.LOGIN=lg
    cobj.save()
    return JsonResponse({'status': 'ok'})

def change_passwordpost_user(request):
    oldpassword = request.POST['oldpassword']
    newpassword = request.POST['newpassword']
    confirmpassword = request.POST['newpassword']
    lid=request.POST['lid']
    print(oldpassword, newpassword,confirmpassword,lid)
    p=User.objects.get(id=lid).password
    print(request.user)
    f = check_password(oldpassword, p)
    if f:
        user = User.objects.get(id=lid)
        user.set_password(newpassword)
        user.save()
        return JsonResponse({'status': 'ok'})
    else:
        return JsonResponse({'status': 'no'})

def add_skill(request):
    lid = request.POST['lid']
    skill = request.POST['skill']

    ob = skill_table()
    ob.skill = skill
    ob.date = datetime.today()
    ob.USER = Users_table.objects.get(LOGIN__id=lid)
    ob.save()
    return JsonResponse({'status': 'ok'})

def deleteskill(request):
    id = request.POST['id']
    ob = skill_table.objects.get(id=id)
    ob.delete()
    return JsonResponse({"status":"ok"})

def view_skill_user(request):
    ob =skill_table.objects.all()
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'skill': i.skill,
             'date': str(i.date),
            'USER': i.USER.name,
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})

def sendfeedback_user(request):
    lid=request.POST['lid']
    feedback = request.POST['feedback']

    k=System_feedback()
    k.feedback=feedback
    k.LOGIN =User.objects.get(id=lid)
    k.date=datetime.today()
    k.save()

    return JsonResponse({'status': 'ok'})

def send_expert_feedback(request):
    lid = request.POST['lid']
    Eid = request.POST['Eid']
    feedback = request.POST['feedback']
    rating = request.POST['rating']

    k=Feedback_table()
    k.feedback=feedback
    k.rating=rating
    k.date=datetime.today()
    k.EXPERT = Expert_table.objects.get(id=Eid)
    k.USER = Users_table.objects.get(LOGIN__id=lid)
    k.save()
    return JsonResponse({'status': 'ok'})

def sendrequest(request):
    lid = request.POST['lid']
    Eid = request.POST['Eid']

    cobj = request_table()
    cobj.date = datetime.today()
    cobj.status = "pending"
    cobj.EXPERT = Expert_table.objects.get(id=Eid)
    cobj.USER = Users_table.objects.get(LOGIN=lid)
    cobj.save()
    print("@@@@@@@@@@@@@@@@@@@@@@@")

    return JsonResponse({
        'status': 'ok',
        'lid': lid,
        'Eid': Eid
    })

def view_expert(request):
    experts = Expert_table.objects.all()
    mdata = []

    for i in experts:
        data = {
            'id': i.id,
            'name': i.name,
            'email': i.email,
            'contact': str(i.contact),
            'qualification': i.qualification,
            'experience': i.experience,
        }
        mdata.append(data)

    return JsonResponse({"status": "ok", "data": mdata})

from django.http import JsonResponse

def view_company(request):
    ob = company_table.objects.all()
    mdata = []
    for i in ob:

        image_url = i.image.url if i.image else ''
        full_image_url = request.build_absolute_uri(image_url)

        data = {
            'id': i.id,
            'name': i.name,
            'email': i.email,
            'contact': str(i.phone),
            'image': full_image_url,
            'bio': i.bio,
            'company_name': i.company_name,
            'LOGIN': i.LOGIN.id,
        }
        mdata.append(data)

    return JsonResponse({"status": "ok", "data": mdata})


def view_notification_user(request):
    ob =Notification_table.objects.all()
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'notification': i.notification,
            'details': i.details,
            'date': str(i.date),

        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})

def view_skills(request):
    ob = skill_table.objects.all()
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'notification': i.notification,
            'details': i.details,
            'date': str(i.date),

        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})

def view_startup_user(request):
    lid=request.POST['lid']
    print(request.POST)
    ob = Startup_idea_table.objects.filter(LOGIN_id=lid)
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'title': i.title,
            'description': i.description,
            'industry': i.industry,
            'LOGIN':i.LOGIN.id
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})

def add_startup_user(request):
    lid=request.POST['lid']
    Title=request.POST['title']
    Description=request.POST['description']
    Industry=request.POST['industry']

    ob=Startup_idea_table()
    ob.LOGIN = User.objects.get(id=lid)
    ob.title=Title
    ob.description=Description
    ob.industry=Industry
    ob.save()
    return JsonResponse({'status': 'ok'})

def Edit_startup_Post(request):
    lid = request.POST['lid']
    id = request.POST['id']
    Title = request.POST["Title"]
    Description=request.POST["Description"]
    Industry=request.POST["Industry"]

    ob=Startup_idea_table.objects.get(id=id)
    ob.LOGIN = User.objects.get(id=lid)
    ob.Title=Title
    ob.Description=Description
    ob.Industry=Industry
    ob.save()
    return JsonResponse({"status":"ok"})

def delete_startup_Post(request):
    id = request.POST['id']
    ob = Startup_idea_table.objects.get(id=id)
    ob.delete()
    return JsonResponse({"status":"ok"})

# def view_trending_startup_user(request):
#     ob = trending_Startup_idea.objects.all()
#     mdata = []
#     for i in ob:
#         data = {
#             'id': i.id,
#             'title': i.title,
#             'description': i.description,
#             'industry': i.industry,
#             'type':i.type,
#         }
#         mdata.append(data)
#     return JsonResponse({"status": "ok", "data": mdata})

def viewprofile_user(request):
    lid = request.POST['lid']
    ob = Users_table.objects.get(LOGIN__id=lid)
    return JsonResponse({
        "status": "ok",
        "name": ob.name,
        "email": ob.email,
        "phone": str(ob.phone),
        "place": ob.place,
        "post":ob.post,
        "pin":str(ob.pin),
        "qualification":ob.qualification,
        "skills":ob.skills,
        "interested_area":ob.interested_area,
    })

def updateprofile_user(request):
    name = request.POST["name"]
    email=request.POST["email"]
    phone=request.POST['phone']
    place=request.POST['place']
    post=request.POST['post']
    pin=request.POST['pin']
    qualification=request.POST['qualification']
    skills=request.POST['skills']
    interested_area=request.POST['interested_area']
    lid=request.POST['lid']
    ob=Users_table.objects.get(LOGIN_id=lid)

    ob.name=name
    ob.email=email
    ob.phone=phone
    ob.place=place
    ob.post=post
    ob.pin=pin
    ob.qualification=qualification
    ob.skills=skills
    ob.interested_area=interested_area
    ob.LOGIN = User.objects.get(id=lid)
    ob.save()
    return JsonResponse({"status":"ok"})

def send_complaint_user(request):
    lid = request.POST['lid']
    complaint=request.POST['complaint']
    ob=Complaint_table()
    ob.complaint=complaint
    ob.reply='pending'
    ob.date=datetime.today()
    ob.USER=Users_table.objects.get(LOGIN__id=lid)
    ob.save()
    return JsonResponse({'status': 'ok',})

def complaintViewflutter(request):
    lid=request.POST['lid']
    ob=Complaint_table.objects.filter(USER__LOGIN__id=lid)
    mdata=[]
    for i in ob:
        data={
            'complaint':i.complaint,
            'reply':i.reply,
            'date':i.date,
        }
        mdata.append(data)
    print(mdata)
    return JsonResponse({'status':'ok','data':mdata})

def send_doubt_user(request):
    lid = request.POST['lid']
    Eid = request.POST['Eid']
    feedback = request.POST['doubt']

    k=doubt_table()
    k.feedback=feedback
    k.reply='pending'
    k.date=datetime.today()
    k.EXPERT = Expert_table.objects.get(id=Eid)
    k.USER = Users_table.objects.get(LOGIN__id=lid)
    k.save()
    return JsonResponse({'status': 'ok'})

def doubt_View_user(request):
    lid = request.POST['lid']
    ob = doubt_table.objects.filter(USER__LOGIN__id=lid)
    mdata = []

    for i in ob:
        data = {
            'id': i.id,
            'feedback': i.feedback,
            'reply': i.reply,
            'date': i.date.strftime("%Y-%m-%d"),
        }
        mdata.append(data)

    return JsonResponse({'status': 'ok', 'data': mdata})

from django.utils import timezone
from django.http import JsonResponse

def User_sendchat(request):
    FROM_id = request.POST['from_id']
    TOID_id = request.POST['to_id']
    msg = request.POST['message']

    c = chat_table()
    c.FROM_id = FROM_id
    c.TO_id = TOID_id
    c.message = msg
    c.time=datetime.now().strftime('%H:%M')
    c.date = timezone.now()
    c.save()
    return JsonResponse({'status': "ok"})

def User_viewchat(request):
    from django.db.models import Q
    fromid = request.POST['from_id']
    toid = request.POST['to_id']

    res = chat_table.objects.filter(
        Q(FROM_id=fromid, TO_id=toid) | Q(FROM_id=toid, TO_id=fromid)
    ).order_by('id')

    l = []
    for i in res:
        l.append({
            "id": i.id,
            "msg": i.message,
            "from": i.FROM_id,
            "to": i.TO_id,
            "date": i.date.isoformat(),
            "time": i.time,
        })

    return JsonResponse({"status":"ok",'data':l})


from django.db.models import Sum


def view_request_status(request):
    lid = request.POST.get('lid')
    ob = Request_table_company.objects.filter(company__LOGIN__id=lid)

    mdata = []
    for i in ob:
        total_fund = Fund_table.objects.filter(request=i).aggregate(Sum('amount'))['amount__sum'] or 0

        data = {
            'id': i.id,
            'date': i.date.strftime("%Y-%m-%d"),
            'STARTUP': i.STARTUP.title,
            'company': i.company.name,
            'status': i.status,
            'total_paid': str(total_fund),  # Pass the aggregated sum
        }
        mdata.append(data)

    return JsonResponse({"status": "ok", "data": mdata})


from django.db.models import Sum


def user_view_request_status(request):
    lid = request.POST['lid']
    # Filter requests where the STARTUP owner is the logged-in user
    ob = Request_table_company.objects.filter(STARTUP__LOGIN_id=lid)

    mdata = []
    for i in ob:
        # Calculate total funds received for this specific request/company pairing
        total_received = Fund_table.objects.filter(request=i).aggregate(Sum('amount'))['amount__sum'] or 0

        data = {
            'id': i.id,
            'date': i.date.strftime("%Y-%m-%d"),
            'STARTUP': i.STARTUP.title,
            'company_name': i.company.company_name,  # Added to show who is investing
            'status': i.status,
            'total_received': str(total_received),
        }
        mdata.append(data)

    return JsonResponse({"status": "ok", "data": mdata})
from django.http import JsonResponse
from .models import request_table

def approve_request(request):
    req=request.POST['req_id']
    Request_table_company.objects.filter(id=req).update(status='accepted')
    return JsonResponse({'status':'ok'})

def reject_request(request):
    req=request.POST['req_id']
    Request_table_company.objects.filter(id=req).update(status='rejected')
    return JsonResponse({'status':'ok'})


from datetime import datetime


def send_fund(request):
    try:
        lid = request.POST['lid']
        request_id = request.POST['request_id']
        amount = request.POST['amount']

        ob = Fund_table()

        ob.amount = int(float(amount))

        ob.date = datetime.today()
        ob.COMPANY = company_table.objects.get(LOGIN__id=lid)
        ob.request = Request_table_company.objects.get(id=request_id)
        ob.save()

        # Update status to paid
        obb = Request_table_company.objects.get(id=request_id)
        obb.status = 'paid'
        obb.save()

        return JsonResponse({'status': 'ok'})
    except Exception as e:
        print(f"Error: {e}")
        return JsonResponse({'status': 'error', 'message': str(e)})

def view_fundoffer_user(request):
    lid = request.POST.get('lid')
    rid = request.POST.get('rid')

    ob = Fund_table.objects.filter(request__STARTUP__LOGIN__id=lid,request_id=rid)
    print("Found:", ob.count())

    mdata = []

    for i in ob:
        data = {
            'id': i.id,
            'COMPANY': i.COMPANY.name,
            'amount': i.amount,
        }
        mdata.append(data)

    return JsonResponse({"status": "ok", "data": mdata})


from collections import Counter
from django.http import JsonResponse
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def NLP_trending_user_Startup(request):
    # Only admin-added startups 222222222222222
    ideas = list(Startup_idea_table.objects.filter(LOGIN_id=1).order_by('-id'))
    print(ideas,"ideas")
    if len(ideas) < 2:
        return JsonResponse({'status':'ok','data':[]})

    # Count the most common description (concept)
    from collections import Counter
    desc_counter = Counter([i.description for i in ideas])
    most_common_desc = desc_counter.most_common(1)[0][0]

    # Index of a startup with that description
    latest_index = next(i for i, idea in enumerate(ideas) if idea.description == most_common_desc)

    # Build documents for TF-IDF
    documents = [f"{i.title} {i.description} {i.industry}".lower() for i in ideas]
    print(documents,"ddddddd")
    vectorizer = TfidfVectorizer(stop_words='english', ngram_range=(1,2))
    tfidf_matrix = vectorizer.fit_transform(documents)
    similarity_matrix = cosine_similarity(tfidf_matrix)

    # Similarity scores for the most common concept
    similarity_scores = list(enumerate(similarity_matrix[latest_index]))

    # Remove self similarity
    similarity_scores = [s for s in similarity_scores if s[0] != latest_index]

    # Sort by similarity DESC
    similarity_scores.sort(key=lambda x: x[1], reverse=True)

    top_indices = [i[0] for i in similarity_scores[:10]]
    print(top_indices,"adsfdfdfd")

    mdata = []
    for idx in top_indices:
        idea = ideas[idx]
        print(idea,"idea")
        try:
            # user = Users_table.objects.get(LOGIN=idea.LOGIN)
            mdata.append({
                'id': str(idea.id),
                'title': idea.title,
                'description': idea.description,
                'industry': idea.industry,
                'uname': idea.LOGIN.username,
                'uemail': idea.LOGIN.email,
                'uphone': str("9999999")
            })
            print(mdata,"mdata")
        except:
            pass
    print(mdata,"mdata")
    return JsonResponse({'status':'ok','data':mdata})


import json
import google.generativeai as genai
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

# Configure your API key
genai.configure(api_key="AIzaSyDhdjkzZ9XMUxlrCnaW2pNMU52Po_U8K2Y")

import json
import google.generativeai as genai
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt




import google.generativeai as genai
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
import os

# Configure your Gemini API Key here
# It is better to store this in an environment variable
GEMINI_API_KEY = "AIzaSyDhdjkzZ9XMUxlrCnaW2pNMU52Po_U8K2Y"
genai.configure(api_key=GEMINI_API_KEY)


def gemini_chat(request):
    if request.method == "POST":
        try:
            body = json.loads(request.body.decode("utf-8"))
            user_msg = body.get("message", "")

            # Advanced Venture Architect Instruction
            system_prompt = (
                "You are 'Nexus-V', an Advanced Venture Architect AI. "
                "Your objective is to provide high-level startup strategy. "
                "If an idea is pitched, respond with this EXACT structure:\n\n"
                "STRATEGIC OVERVIEW: (1-sentence critique)\n"
                "SCALABILITY SCORE: (0-100%)\n"
                "MARKET POSITIONING: (Target audience analysis)\n"
                "GROWTH ROADMAP: (3-step technical execution)\n"
                "REVENUE CHANNELS: (Monetization strategy)\n\n"
                "Use professional, sophisticated language. Avoid symbols like **."
            )

            model = genai.GenerativeModel(
                model_name="gemini-2.5-flash",
                system_instruction=system_prompt
            )

            response = model.generate_content(user_msg)
            return JsonResponse({"status": "ok", "response": response.text.replace("**", "")})

        except Exception as e:
            return JsonResponse({"status": "error", "message": str(e)})

    return JsonResponse({"status": "error", "message": "Invalid Method"})


# def NLP_trending_user_Startup(request):
#     # Only admin-added startups 111111111111111111
#     ideas = list(Startup_idea_table.objects.filter(LOGIN_id=1).order_by('-id'))
#
#     if len(ideas) < 2:
#         return JsonResponse({'status': 'ok', 'data': []})
#
#     # Count the most common description (concept)
#     from collections import Counter
#     desc_counter = Counter([i.description for i in ideas])
#     most_common_desc = desc_counter.most_common(1)[0][0]
#
#     # Index of a startup with that description
#     latest_index = next(i for i, idea in enumerate(ideas) if idea.description == most_common_desc)
#
#     # Build documents for TF-IDF
#     documents = [f"{i.title} {i.description} {i.industry}".lower() for i in ideas]
#
#     vectorizer = TfidfVectorizer(stop_words='english', ngram_range=(1, 2))
#     tfidf_matrix = vectorizer.fit_transform(documents)
#     similarity_matrix = cosine_similarity(tfidf_matrix)
#
#     # Similarity scores for the most common concept
#     similarity_scores = list(enumerate(similarity_matrix[latest_index]))
#
#     # Remove self similarity
#     similarity_scores = [s for s in similarity_scores if s[0] != latest_index]
#
#     # Sort by similarity DESC
#     similarity_scores.sort(key=lambda x: x[1], reverse=True)
#
#     top_indices = [i[0] for i in similarity_scores[:10]]
#
#     mdata = []
#     for idx in top_indices:
#         idea = ideas[idx]
#         try:
#
#             mdata.append({
#                 'id': str(idea.id),
#                 'title': idea.title,
#                 'description': idea.description,
#                 'industry': idea.industry,
#                 'uname': idea.LOGIN.name,
#                 'uemail': idea.LOGIN.email,
#
#             })
#         except:
#             pass
#
#     return JsonResponse({'status': 'ok', 'data': mdata})


from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


def similarity_fn(para1, para2):
    vectorizer = TfidfVectorizer(stop_words='english')
    tfidf = vectorizer.fit_transform([para1, para2])

    similarity_score = cosine_similarity(tfidf[0:1], tfidf[1:2])[0][0]

    print("Similarity:", similarity_score)
    return similarity_score


def NLP_trending_Admin_Startup(request):
    # Only admin-added startups
    lid = request.POST['lid']
    ob = skill_table.objects.filter(USER__LOGIN__id=lid)
    txt = ""
    for i in ob:
        txt += i.skill + " "
    ideas = list(Startup_idea_table.objects.exclude(LOGIN__id=lid).order_by('-id'))

    if len(txt) < 5:
        return JsonResponse({'status': 'ok', 'data': []})
    sim_list = []
    for i in ideas:

        sim = similarity_fn(txt, i.description)
        if sim > 0.2:
            sim_list.append({"id": i.id, "sim": sim})
    sorted_sim_list = sorted(sim_list, key=lambda x: x["sim"], reverse=True)
    top_indices = []
    for i in range(len(sorted_sim_list)):
        top_indices.append(sorted_sim_list[i]['id'])
        if len(top_indices) >= 5:
            break
    mdata = []

    for idx in top_indices:
        idea = Startup_idea_table.objects.get(id=idx)

        try:
            obu=Users_table.objects.get(LOGIN__id=idea.LOGIN.id)

            mdata.append({
                'id': str(idea.id),
                'title': idea.title,
                'description': idea.description,
                'industry': idea.industry,
                'uname': obu.name,
                'uemail': obu.email,
                'uphone': str(obu.phone)

            })
        except Exception as e:
            mdata.append({
                'id': str(idea.id),
                'title': idea.title,
                'description': idea.description,
                'industry': idea.industry,
                'uname': idea.LOGIN.username,
                'uemail': idea.LOGIN.email,
                'uphone': str("9999999")

            })
            print(e)

    print(mdata)
    return JsonResponse({'status': 'ok', 'data': mdata})


from django.db.models import Sum
from django.http import JsonResponse
from .models import Fund_table, company_table


def investor_portfolio_dashboard(request):
    try:
        lid = request.POST.get('lid')
        # Get the company object linked to the login
        company = company_table.objects.get(LOGIN__id=lid)

        # 1. Total Invested Amount
        total_invested = Fund_table.objects.filter(COMPANY=company).aggregate(Sum('amount'))['amount__sum'] or 0

        # 2. Available Balance
        # (Assuming a logic: Total Budget - Total Invested. Using 10 Lakhs as a base for demo)
        total_budget = 1000000
        available_balance = total_budget - total_invested

        # 3. Insights: Group by Industry
        # We query Fund_table, traversing through request -> STARTUP -> industry
        industry_data = Fund_table.objects.filter(COMPANY=company).values(
            'request__STARTUP__industry'
        ).annotate(total=Sum('amount'))

        insights = []
        for entry in industry_data:
            insights.append({
                'industry': entry['request__STARTUP__industry'],
                'amount': entry['total']
            })

        return JsonResponse({
            "status": "ok",
            "balance": str(available_balance),
            "invested": str(total_invested),
            "insights": insights
        })
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})











    #######################forgotpassword######################



def user_Forgot_password(request):

        email = request.POST['email']

        us = Users_table.objects.filter(email=email)

        if us.exists():

            try:

                lg = Users_table.objects.get(email=email)

                bb = User.objects.get(id=lg.Login_id)

                password = random.randint(00000000, 99999999)

                bb.set_password(str(password))

                bb.save()

                sender_email = "mhdfadilbussiness@gmail.com"

                sender_password = "cxzw efhx bujd qrni"

                subject = "Forget Password From SignSpeak"

                body = f"Your New Password Is ({password}).Please Change Password After Login."

                msg = MIMEMultipart()

                msg['From'] = sender_email

                msg['To'] = email

                msg['Subject'] = subject

                msg.attach(MIMEText(body, 'plain'))

                server = smtplib.SMTP(host="smtp.gmail.com", port=587)

                server.starttls()

                server.login(sender_email, sender_password)

                server.sendmail(sender_email, email, msg.as_string())

                server.quit()

                print(f"Email sent successfully to {email}")

                return JsonResponse({"status": "ok"})

            except Exception as e:

                print(f"Error sending email: {e}")

                return JsonResponse({"status": "no"})



####################################





def chat1(request,id):
    request.session["userid"] = id
    cid = str(request.session["userid"])
    request.session["new"] = cid
    qry = Users_table.objects.get(LOGIN=cid)

    return render(request, "expert/Chat.html", {'photo': '/static/user.jpg', 'name': qry.name, 'toid': cid})

def chat_view(request):
    fromid = request.user.id
    toid = request.session["userid"]
    qry = Users_table.objects.get(LOGIN=request.session["userid"])
    from django.db.models import Q

    res = chat_table.objects.filter(Q(FROM_id=fromid, TO_id=toid) | Q(FROM_id=toid, TO_id=fromid))
    l = []

    for i in res:
        l.append({"id": i.id, "message": i.message, "to": i.TO_id, "date": i.date, "from": i.FROM_id})

    return JsonResponse({'photo': '/static/user.jpg', "data": l, 'name': qry.name, 'toid': request.session["userid"]})

def chat_send(request, msg):
    lid = request.user.id
    toid = request.session["userid"]
    message = msg

    import datetime
    d = datetime.datetime.now().date()
    chatobt = chat_table()
    chatobt.message = message
    chatobt.TO_id = toid
    chatobt.FROM_id = lid
    chatobt.date = d
    chatobt.save()

    return JsonResponse({"status": "ok"})


#
#
# def User_sendchat(request):
#     FROM_id=request.POST['from_id']
#     TOID_id=request.POST['to_id']
#     print(FROM_id)
#     print(TOID_id)
#     msg=request.POST['message']
#
#     from  datetime import datetime
#     c=Chat()
#     c.FROMID_id=FROM_id
#     c.TOID_id=TOID_id
#     c.message=msg
#     c.date=datetime.now()
#     c.save()
#     return JsonResponse({'status':"ok"})
#
#
# def User_viewchat(request):
#     fromid = request.POST["from_id"]
#     toid = request.POST["to_id"]
#     # lmid = request.POST["lastmsgid"]
#     from django.db.models import Q
#
#     res = Chat.objects.filter(Q(FROMID_id=fromid, TOID_id=toid) | Q(FROMID_id=toid, TOID_id=fromid))
#     l = []
#
#     for i in res:
#         l.append({"id": i.id, "msg": i.message, "from": i.FROMID_id, "date": i.date, "to": i.TOID_id})
#
#     return JsonResponse({"status":"ok",'data':l})
#
#
#






def send_request_toexpert(request):
    try:
        lid = request.POST['lid']
        sid = request.POST['eid']
        idea = request.POST.get('requested_idea', '') # Get idea from Flutter

        # Logic: Create a new request every time this is called
        cobj = Request_table_expert()
        cobj.date = datetime.today()
        cobj.status = "pending"
        cobj.request = idea # Ensure your model field name matches 'request'
        cobj.EXPERT = Expert_table.objects.get(id=sid)
        cobj.USER = Users_table.objects.get(LOGIN__id=lid)
        cobj.save()

        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})



def view_userrequest_get(request):
    res=Request_table_expert.objects.filter(EXPERT__LOGIN_id=request.user.id)
    return render(request,'expert/view_request_&_verify.html',{'data':res})


import google.generativeai as genai
import os
from django.conf import settings
from django.http import JsonResponse

# Configuration for Startup Analysis
genai.configure(api_key=getattr(settings, 'GEMINI_API_KEY', os.getenv('GEMINI_API_KEY')))
model = genai.GenerativeModel("gemini-2.5-flash")


def analyze_startup_proposal(idea_text):
    print("--- Startup Analysis Started ---")

    # Custom prompt for startup prediction
    prompt = f"""
    You are an AI Startup Strategist and Venture Capitalist. 
    Analyze the following project proposal: "{idea_text}"

    Please provide your response in this exact structured format:
    1. **Success Probability**: (0-100% with a short reason for the score)
    2. **Market Fit**: (Critical analysis of whether the world needs this)
    3. **Implementation Plan**: (3 high-level steps to make this AI/Product work)
    4. **Potential Roadblocks**: (Identify 2 major risks)
    5. **Final Recommendation**: (Invest/Watch/Pivot)

    Keep the tone professional, blunt, and highly analytical.
    """

    try:
        response = model.generate_content(prompt)
        if response and response.text:
            return {"status": "success", "prediction": response.text}
        else:
            return {"status": "error", "message": "AI Engine returned no data."}
    except Exception as e:
        return {"status": "error", "message": f"AI Engine Error: {str(e)}"}


# Django AJAX View
def ajax_analyze_startup(request):
    if request.method == "POST":
        idea = request.POST.get('idea')
        # You can add the request_id to a model later to log this analysis
        result = analyze_startup_proposal(idea)
        return JsonResponse(result)
    return JsonResponse({"status": "error", "message": "Method not allowed"})


def expertacceptrequest(request,id):
    a=Request_table_expert.objects.filter(id=id).update(status='accepted')
    messages.success(request,'request Approved')
    return redirect('/myapp/view_userrequest_get/')

def expertrejectrequest(request,id):
    a=Request_table_expert.objects.filter(id=id).update(status='rejected')
    messages.success(request,'request rejected')
    return redirect('/myapp/view_userrequest_get/')


from django.http import JsonResponse
from .models import *
import google.generativeai as genai

# Configuration for AI Analysis (Same as Expert View)
genai.configure(api_key="AIzaSyDhdjkzZ9XMUxlrCnaW2pNMU52Po_U8K2Y")
model = genai.GenerativeModel("gemini-2.5-flash")


def ViewExpertRequestStatus(request):
    try:
        lid = request.POST.get('lid')
        # Fetching requests for this specific user
        requests = Request_table_expert.objects.filter(USER__LOGIN_id=lid).order_by('-id')

        data_list = []
        for i in requests:
            data_list.append({
                'id': i.id,
                'expert_name': i.EXPERT.name,
                'expert_lid': i.EXPERT.LOGIN.id,  # Passing Expert Login ID for Chat
                'date': i.date.strftime('%Y-%m-%d'),
                'status': i.status,
                'idea': i.request,  # The original idea text
            })

        return JsonResponse({'status': 'ok', 'data': data_list})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})


# Dynamic AI Analysis for User
def user_analyze_idea(request):
    idea_text = request.POST.get('idea')

    prompt = f"""
    You are a Startup Advisor. Analyze this project idea: "{idea_text}"
    Provide:
    1. Success Probability (0-100%)
    2. 3 Key Recommendations to improve it.
    3. Market Feasibility.
    Be concise and professional.
    """

    try:
        response = model.generate_content(prompt)
        return JsonResponse({'status': 'ok', 'analysis': response.text})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})