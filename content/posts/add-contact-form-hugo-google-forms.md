+++
title = "Add Contact form to Hugo with Google forms"
date = "2020-11-02T21:25:36+05:30"
author = "KD Puvvadi"
authorTwitter = "kdpuvvadi" #do not include @
cover = ""
tags = ["Hugo", "Google Forms", "Contact form", "HTML", "CSS", "Static Site" ]
keywords = ["Dev"]
description = "Add contact form to Hugo Static site using Google Forms"
showFullContent = false
+++

Hugo is great for a static site. No need for complecated setups, no database or data tobe hacked. static sites have ton of advantages but when it comes to dynamic content like contact form it is little bit complecated to setup. I'm gonna use Google Forms to setup Contact form on Hugo Static site with custom thank you page on submit.

![Google Forms](/image/google-forms.jpg)

First open [Google form](https://www.google.com/forms/about/) and create a form with *Name, Email, Subject and Message*.

![](/image/contact-form-google-form-fields.png)


Now create new page with following

````
$ hugo new contact.md
````
To fill the google form from our site you need *form id* and *field ids*. Now open the form in incongnito mode to get the field ids and make a note of them.

![](/image/google-form-fields.png)

if you don't have *Raw HTML* layout for your site, HTML content may not render properly. If you've *rawhtml* layout, you can skip this step.
To add *rawhtml* layout create rawhtml.html file in your theme directory *layouts > shortcodes > rawhtml.html*. Add fowlling code to the file, save and exit. 

````
<!-- raw html -->
{{.Inner}}
````
Add rawhtml tag in *contact.md*

![](/image/rawhtml.jpg)

Now add following to your *contact.md* file and replace the form ID and field IDs from previous. 

{{< code language="html"  expand="Show" collapse="Hide" >}}

<form action="https://docs.google.com/forms/d/e/<formID/formResponse" method="post" target="hidden_iframe" onsubmit="submitted=true">
        <label>Name*</label>
        <input type="text" placeholder="Name*" class="feedback-input" name="entry.719211028" required>

        <label>Email*</label>
        <input type="email" placeholder="Email address*" class="feedback-input" name="entry.1119409224" required>

        <label>Subject*</label>
        <input type="text" placeholder="Subject*" class="feedback-input" name="entry.1043109960" required>
    
        <label>Message</label>
        <textarea rows="5" placeholder="Message" class="feedback-input" name="entry.1348223678" ></textarea>
    
        <button type="submit">Send</button>
</form>

{{< /code >}}

*Replace FormID with actual ID from Google form*

Create *form.css* file inside *static > css * directory and add following to it.

{{< code language="css" expand="Show" collapse="Hide"  >}}

@import url(https://fonts.googleapis.com/css?family=Montserrat:400,700);

form { max-width:420px; margin:50px auto; }

.feedback-input {
color:white;
font-family: Helvetica, Arial, sans-serif;
font-weight:500;
font-size: 18px;
border-radius: 5px;
line-height: 22px;
background-color: transparent;
border:2px solid #CC6666;
transition: all 0.3s;
padding: 13px;
margin-bottom: 15px;
width:100%;
box-sizing: border-box;
outline:0;
}

.feedback-input:focus { border:2px solid #CC4949; }

textarea {
height: 150px;
line-height: 150%;
resize:vertical;
}

[type="submit"] {
font-family: 'Montserrat', Arial, Helvetica, sans-serif;
width: 100%;
background:#CC6666;
border-radius:5px;
border:0;
cursor:pointer;
color:white;
font-size:24px;
padding-top:10px;
padding-bottom:10px;
transition: all 0.3s;
margin-top:-4px;
font-weight:700;
}
[type="submit"]:hover { background:#CC4949; }

{{< /code >}}


Now add following line to link the CSS to the form. 

````
<link rel="stylesheet" href="/css/form.css">
````

Now try filling and submitting the form. You may've obsrved that after submition, page is redirecting to default Google form resnponse page. To fix it first create a new page with following

````
$ hugo new thankyou.md
````
Add following to contact page html just before *form* tag.

{{< code language="html"  expand="Show" collapse="Hide" >}}
<script type="text/javascript">var submitted=false;</script>
<iframe name="hidden_iframe" id="hidden_iframe" style="display:none;" 
onload="if(submitted) {window.location='/thankyou';}"></iframe>

<form action="https://docs.google.com/forms/d/e/<formID>/formResponse" 
method="post" target="hidden_iframe" onsubmit="submitted=true;">
</form>
{{< /code >}}

*Replace FormID with actual ID from Google form*.

#### Now it should looks something like this bellow.

![](/image/contact-form.jpg)

After submitting the form, it should redirect to */thankyou/* page.

![](/image/contact-res.png)

Here we go, your Static Hugo site have a dynamic contact form. If you want to receive emails everytime someone fillsout the form, go to rensponses on Google Form and Check *get email notifications for new rensponses*. 

![](/image/google-form-res-email.jpg)

You can also export all the response to *csv* format or directly Google spreadsheets. 

### Conclusion

Without going with costly hosting and all that, you can host your Static sites with Netlify, Cloudflare Apps etc for free. All you've do is invest little time. Push the code to Github and site will be auto build and deployed. Now, Contact forms can be intigrated with single line for certain price from certain service providers but Google form is free and can simply be added to static sites. 