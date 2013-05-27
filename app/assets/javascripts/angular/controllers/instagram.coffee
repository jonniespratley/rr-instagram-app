# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class @InstagramController
  #App = angular.module('App', ['$strap.directives', 'ui.bootstrap'])
  
  InstagramController = ($scope, $http, $timeout) ->
     
    $scope.App = 
      title: 'R&R Instagram App'
      build : '0.0.2'
      description : 'Using Instagram\'s popular media API (http://instagram.com/developer/endpoints/media/#get_media_popular), this webapp shows popular images in a grid that refreshes automatically.'
      data : 
        timestamp: new Date()
        items: null
      selectedTile: null
      loading: false
      current_page: 'Recent'
      user: 
        access_token: null
      model : 
        filters : []
        query: null
      settings :
        debug : true
      #Timeout reference
      timeoutid: null
      #Handle initializing the application
      init: (args) ->
        setInterval(() -> 
          $scope.App.getRecent()
        30000)
        
        @initIsotope()
        @getRecent()
        @Instagram.init('42af9189076c4ce7903df62e8afa2009', 'http://jonniespratley.me:3000/instagram/callback')
        
   
      #Handle loggin to the console
      log: (args) ->
        console.log(args);
        
      #Handle making ajax calls to backend
      getData:(what, params) ->
        self = @
        $scope.App.loading = true
        $http.get("/instagram/#{what}.json", {params: params}).success((data) ->
          $scope.App.loading = false
          $scope.App.data.timestamp = new Date()
          $scope.App.data.items = data
          $scope.App.changeAllImages()
          #$timeout($scope.App.changeAllImages, 1000);
        );
      #Handle getting recent images
      getRecent:() ->
        @current_page = 'Recent'
        @getData('recent')
      #Handle getting popular images
      getPopular: () ->
        @current_page = 'Popular'
        @getData('popular')
      #Handle getting trending images
      getTrending: () ->
        @current_page = 'Trending'
        @getData('trending')
      #Handle searching instagram by username
      search: () ->
        @current_page = 'Search'
        @getData('search', {query: $scope.App.model.query})
      #Handle when tile is selected
      selectTile: (item) ->
        @log(item);
        @selectedTile = item;
        
      #Handle hidding each image one by one
      changeAllImages: () ->
        self = @;
        angular.forEach( $scope.App.data.items, (item, index) ->
            self.changeImage(index, item.images.low_resolution.url);
            console.log(item, index);
          )
        
      #Handle showing each image one by one 
      showAllImages: () ->
        
           
      #Handle initializing isotope plugin
      initIsotope: ->
        
        angular.element('#tile-grid').isotope({
          itemSelector: '.item'
          layoutMode: 'fitRows'
        });  
        
        
      #Handle adding a image to the grid
      addImage: (img) ->
        $newItems = angular.element('<div class="item"><img src="http://placehold.it/200x200&text=1"/></div>');
        angular.element('#tile-grid').append($newItems).isotope('addItems', $newItems);
        angular.element('#tile-grid').isotope('reloadItems');
        #@initIsotope()
        
      #Handle changing the image when refreshed
      changeImage: (el, image) ->
        element = angular.element("#tile_#{el}").find('img.pic');
        element.fadeOut('slow',() ->
          element.attr('src', image)
          element.fadeIn('slow')
        )
      
      #============ INSTAGRAM API ==============
      Instagram:
        client_id: '42af9189076c4ce7903df62e8afa2009'
        client_secret: '5690ec482a8f4f818daf898065ecc1c7'
        redirect_uri: 'http://jonniespratley.me:3000/instagram/callback'
        code: null
        access_token: null
        auth_url: null
        
        #Handle initializing Instagram API
        init: (client_id, redirect_uri) ->
          $scope.App.Instagram.client_id = client_id
          $scope.App.Instagram.redirect_uri = redirect_uri
      
        #Handle authenticate a user
        authorize: () ->
          url = "https://instagram.com/oauth/authorize/?client_id=#{$scope.App.Instagram.client_id}&redirect_uri=#{$scope.App.Instagram.redirect_uri}&response_type=token"
          window.location = url
          console.log(url)
        
        #Handle getting the access_token from the url
        checkAccessToken: () ->
          hash_value = window.location.hash.split('=') if window.location.hash
          @saveAccessToken(hash_value[1]) if hash_value
        
        #Handle saving access token to storage
        saveAccessToken: (token) ->
          $scope.App.Instagram.access_token = token
          console.log(token)
       
       
     #Handle setting on window
     window.App = $scope.App;
     
