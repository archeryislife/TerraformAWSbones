# Terraform

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
A couple of notes;
1.  This is a bear bones setup of a VPC, Public subnet, and two Private subnets. It also contains all the required infrastructure and route tables to make
    a SSH connection to a single ec2 instance created. Where you want to take this from here is up to you.
2.  setup a key pair in the console before running this code, use that key when it calls for user input. Once it comes time to destory you can loose the
     pair during tear down. 
3.  If you prefer to not accept defaults open up the variables.tf file and find "default" and replace with "#default" for any variables you wish to be
     prompted for.
4.  I didn't make this for any particular reason other than to teach myself TF(terraform) and be able to quickly build out infrastructure for testing other stuff.       If you have suggestions or want to fork it feel free and have fun!! :)
5.  If you are new to TF(terraform) please go watch the following youtube video, it is not mine but is a really good to get beginners started.
    https://www.youtube.com/watch?v=SLB_c_ayRMo
6.  The providers.tf file is setup to be used with shared credentials in the .aws directory in your linux home directory. You will probably want to customize
    this to your setup before running the code
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
