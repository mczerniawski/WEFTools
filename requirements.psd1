@{
  Pester = @{
    Name = 'Pester'
    DependencyType ='PSGalleryModule'
    Parameters =@{
      Repository = 'PSGallery'
      SkipPublisherCheck = $true
    }
  }
  PSWinReportingV2 = "Latest"
}
