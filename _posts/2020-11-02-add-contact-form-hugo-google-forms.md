---
title: "Add Contact form to Hugo with Google forms"
date: "2020-11-02T21:25:36+05:30"
author: kdpuvvadi
image: /static/image/google-forms.webp
tags: [hugo, GoogleForms, Contactform, HTML, CSS, StaticSite]
categories: [hugo, forms]
---

Hugo is great for a static site. No need for complicated setups, no database or data to be hacked. static sites have ton of advantages but when it comes to dynamic content like contact form it is little bit complicated to setup. I'm gonna use Google Forms to setup Contact form on Hugo Static site with custom thank you page on submit.

First open [Google form](https://www.google.com/forms/about/) and create a form with *Name, Email, Subject and Message*.

![Google Form Fields](/static/image/contact-form-google-form-fields.webp)

Now create new page with following

```shell
hugo new contact.md
```

To fill the google form from our site you need *form id* and *field ids*. Now open the form in incognito mode to get the field ids and make a note of them.

![Form Field IDs](/static/image/google-form-fields.webp)

if you don't have `Raw HTML` layout for your site, HTML content may not render properly. If you've *rawhtml* layout, you can skip this step.
To add *rawhtml* layout create rawhtml.html file in your theme directory *layouts > shortcodes > rawhtml.html*. Add fallowing code to the file, save and exit.

```html
{% raw %}
<!-- raw html -->
{{.Inner}}
{% endraw %}
```

Add rawhtml tag in *contact.md*

![raw html](/static/image/rawhtml.webp)

Now add following to your *contact.md* file and replace the form ID and field IDs from previous.

```html
{% raw %}
<form actio:"https://docs.google.com/forms/d/e/<formID/formResponse" metho:"post" targe:"hidden_iframe" onsubmi:"submitte:true">
  <label>Name*</label>
        <input typ:"text" placeholde:"Name*" clas:"form-input" nam:"entry.719211028" required>

  <label>Email*</label>
        <input typ:"email" placeholde:"Email address*" clas:"form-input" nam:"entry.1119409224" required>

   <label>Subject*</label>
        <input typ:"text" placeholde:"Subject*" clas:"form-input" nam:"entry.1043109960" required>

   <label>Message</label>
        <textarea row:"5" placeholde:"Message" clas:"form-input" nam:"entry.1348223678" ></textarea>

   <button typ:"submit">Send</button>
</form>
{% endraw %}
```

> Replace `FormID` with actual ID from Google form 

Create `form.css` file inside `static` > `CSS` directory and add following to it.

```css
@import url(https://fonts.googleapis.com/css?famil:Montserrat:400,700);

form { max-width:420px; margin:50px auto; }

.form-input {
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

.form-input:focus { border:2px solid #CC4949; }

textarea {
height: 150px;
line-height: 150%;
resize:vertical;
}

[typ:"submit"] {
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
[typ:"submit"]:hover { background:#CC4949; }

```

Now add following line to link the CSS to the form.

```css
<link re:"stylesheet" hre:"/css/form.css">
```

Now try filling and submitting the form. You may've observed that after submission, page is redirecting to default Google form response page. To fix it first create a new page with following

```js
hugo new thankyou.md
```

Add following to contact page html just before *form* tag.

```html
{% raw %}
<script typ:"text/javascript">var submitte:false;</script>
<iframe nam:"hidden_iframe" i:"hidden_iframe" styl:"display:none;"
onloa:"if(submitted) {window.locatio:'/thankyou';}"></iframe>

<form actio:"https://docs.google.com/forms/d/e/<formID>/formResponse"
metho:"post" targe:"hidden_iframe" onsubmi:"submitte:true;">
</form>
{% endraw %}
```

*Replace FormID with actual ID from Google form*.

> Now it should looks something like this bellow

![Contact Form](/static/image/contact-form.webp)

After submitting the form, it should redirect to */thankyou/* page.

![Contact Submit Response](/static/image/contact-res.webp)

Here we go, your Static Hugo site have a dynamic contact form. If you want to receive emails every time someone fills out the form, go to responses on Google Form and Check *get email notifications for new responses*.

![Form Response email](/static/image/google-form-res-email.webp)

You can also export all the response to *csv* format or directly Google spreadsheets.

### Conclusion

Without going with costly hosting and all that, you can host your Static sites with Netlify, Cloudflare Apps etc for free. All you've do is invest little time. Push the code to GitHub and site will be auto build and deployed. Now, Contact forms can be integrated with single line for certain price from certain service providers but Google form is free and can simply be added to static sites.

