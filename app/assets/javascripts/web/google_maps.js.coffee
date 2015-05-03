class GoogleMapClass
  constructor: ->
    @_domRoot = null
    @_mapsInitialized = false
    @_booted = false
    @_map = null
    @_filters = {}
    @_markers = {}
    @_venues = {}

  onMapsInitialized: ->
    @_mapsInitialized = true
    @_tryBooting()

  onMapsDomRoot: (domRoot) ->
    @_domRoot = domRoot
    @_tryBooting()

  setFilters: (filters) ->
    @_filters = filters
    for _, venue of @_venues
      @_processVenue venue

  _tryBooting: ->
    return if @_booted
    return if @_domRoot is null or !@_mapsInitialized
    @_booted = true
    @_boot()

  _boot: ->
    options =
        center: { lat: -34.397, lng: 150.644 },
        zoom: 13
    @_map = new google.maps.Map(@_domRoot, options)
    @_bootGeolocation()
    @_readVenues()

  _readVenues: ->
    Liveworx.Venues.readAll()
        .then (venues) =>
          @_processVenue(venue) for venue in venues

  _processVenue: (venue) ->
    @_venues[venue.id] = venue
    if venue.id of @_markers
      marker = @_markers[venue.id]
    else
      marker = new google.maps.Marker()
      @_markers[venue.id] = marker
      google.maps.event.addListener marker, 'click',
          @_onMarkerClick.bind(@, venue.id)

    if @_matchesFilters venue
      marker.setMap @_map
    else
      marker.setMap null
    marker.setIcon venue.icon_url
    marker.setPosition new google.maps.LatLng(venue.lat, venue.long)
    marker.setTitle venue.name

  _matchesFilters: (venue) ->
    for name, value of @_filters
      continue unless value is true
      return false unless venue.filters[name] is true
    true

  _onMarkerClick: (venueId, event) ->
    venue = @_venues[venueId]
    infoWindow = new google.maps.InfoWindow(content: venue.name)
    infoWindow.open @_map, @_markers[venueId]

  # Tries to center the map using the user's location.
  _bootGeolocation: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition(@_onLocation.bind(@),
          @_onLocationFailure.bind(@, true))
    else
      # Browser does not support Geolocation
      @_onLocationFailure false

  # Called when we get a result from the W3C geolocation API.
  _onLocation: (position) ->
    pos = new google.maps.LatLng(position.coords.latitude,
                                 position.coords.longitude)
    @_map.setCenter(pos)

  # Called when we fail to use the W3C geolocation API.
  #
  # @param {Boolean} errorFlag true when the browser supports the API, but the
  #   user didn't allow us to use it
  _onLocationFailure: (errorFlag) ->
    if errorFlag
      content = 'Error: The Geolocation service failed.'
    else
      content = 'Error: Your browser does not support geolocation.'

    infowindow = new google.maps.InfoWindow { content: content }

window.Liveworx ||= {}
window.Liveworx.GoogleMap = new GoogleMapClass()
window.__googleMapsInitialized = ->
  Liveworx.GoogleMap.onMapsInitialized()

$ ->
  container = $ '#google-maps-container'
  if container.length > 0
    Liveworx.GoogleMap.onMapsDomRoot container[0]
    Liveworx.Filters.onChange = ->
      Liveworx.GoogleMap.setFilters Liveworx.Filters.filters
    Liveworx.GoogleMap.on
