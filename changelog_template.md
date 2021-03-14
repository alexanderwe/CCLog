# Changelog 


## Unreleased

{% for release in releases %}  
## [{{ release.version.value }}] - {{ release.date }}

{% for change in release.changeSet.changes %}  
- {{ change.type }} - ({{ change.scope  }}) {{change.description}}
{% endfor %}
{% endfor %}
