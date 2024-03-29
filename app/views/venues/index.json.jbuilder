json.array! @venues do |venue|
  json.id venue.id
  json.name venue.name
  json.lat venue.lat
  json.long venue.long
  json.icon_name venue.sensors['icon']
  json.icon_url venue_icon_url(venue)
  json.people venue.sensors['people']
  json.address venue.address
  json.phone venue.phone
  json.userWarnings venue.sensors['userWarnings']
  json.filters do
    json.food venue.sensors['hasFood']
    json.heat venue.sensors['hasHeat']
    json.power venue.sensors['hasPower']
    json.water venue.sensors['hasWater']
  end
end
