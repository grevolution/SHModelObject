Pod::Spec.new do |s|
  s.name         	= "SHModelObject"
  s.version      	= "1.1.4"

  s.summary      	= "`SHModelObject` a utility class that reads NSDictionary and populates the instance variables and properties automatically."

  s.description  	= <<-DESC
                   `SHModelObject` is a utility Modal Base Class that uses objective-c runtime to assign 
                   the values to instance variables and properties of the model class from an `NSDictionary`, 
                   Which is a basic usecase when using webservices that return JSON response.
                   DESC

  s.homepage     	= "https://github.com/grevolution/SHModelObject"
  s.license      	= {:type => 'MIT'}
  s.author       	= { "Shan Ul Haq" => "g@grevolution.me" }

  s.platform     	= :ios, '7.0'
  s.source       	= { :git => "https://github.com/grevolution/SHModelObject.git", :tag => s.version }

  s.requires_arc	= true
  #s.source_files  	= 'SHModelObject/SHModelObject/*.{h,m}'
  #s.exclude_files 	= 'Classes/Exclude'
  #s.dependency 'Realm'

  s.subspec 'Core' do |core|
    core.source_files = 'SHModelObject/SHModelObject/SHModelObject.{h,m}' , 'SHModelObject/SHModelObject/SHConstants.h' , 
    'SHModelObject/SHModelObject/SHModelSerialization.h'
    core.exclude_files   = 'SHModelObject/SHModelObject/SHRealmObject.{h,m}'
    core.platform      = :ios
  end

  s.subspec 'Realm' do |realm|
    realm.source_files = 'SHModelObject/SHModelObject/SHRealmObject.{h,m}' , 'SHModelObject/SHModelObject/SHConstants.h' , 'SHModelObject/SHModelObject/SHModelSerialization.h'
    realm.platform      = :ios, '7.0'
    realm.exclude_files = 'SHModelObject/SHModelObject/SHModelObject.{h,m}'
    realm.dependency 'Realm'
  end

end
