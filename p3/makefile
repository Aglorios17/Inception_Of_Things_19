#Starts the whole app
all:
	./setup.sh

#Reloads the whole app
re:
	./fclean.sh
	./setup.sh

#Remove the whole app
clean:
	./fclean.sh

#Create the argo-cd app (if kubernetes cluster with argo-cd controller already exists)
launch:
	./launch.sh

#Reload the argo-cd app
re_launch:
	./clean.sh
	./launch.sh

#Remove the argo-cd app
clean_launch:
	./clean.sh
