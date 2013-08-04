Application.directive "scopeBar", ['$timeout'], ($timeout) ->
  replace: true
  template: """
  <div ng-cloak ng-class="gallery" class="scope-bar">
    <div class="status-scope">
      <span ng-show="hovered_rule.scope" class="f-scope type-entity">{{ hovered_rule.scope }}</span>
      <span ng-show="hovered_rule.name" class="f-scope type-entity-text">({{ hovered_rule.name }})</span>
    </div>
  </div>
  """
  link: (scope, element, attr) ->
    preview = $("#preview")
    preview.bind "mouseover", (event) ->
      active = {}
      active.scope = event.target.dataset.entityScope

      if active.scope
        active_scope_rule = getScopeSettings(active.scope)
        active.name = active_scope_rule.name if active_scope_rule

      scope.$apply ->
        # Highlight in sidebar
        scope.$parent.hovered_rule = active_scope_rule
        tmp = -> $(".hovered")[0]?.scrollIntoView()
        $timeout tmp,200

    preview.bind "mouseout", (event) ->
      # Unhighlight in sidebar
      scope.$parent.hovered_rule = null

    preview.bind "dblclick", (event) ->
      active = {}
      active.scope = event.target.dataset.entityScope

      if active.scope
        active_scope_rule = getScopeSettings(active.scope)
        showPopover active_scope_rule, event


    showPopover = (rule, event) ->
      scope.$apply ->
        scope.$parent.new_popover_visible = false
        scope.$parent.popover_rule = rule
        scope.$parent.edit_popover_visible = true

      popover = $("#edit-popover")

      if popover.is('.slide')
        left_offset = $("#gallery").width()
      else
        left_offset = 0

      offset =
        left: (popover.width() / 2) + 10 + left_offset
        top: 24

      popover.css({
        "left": event.pageX - offset.left
        "top": event.pageY + offset.top
      }).addClass("on-bottom")


    # Finds the best matching rule from theme, given the current scope
    getScopeSettings = (active_scope) ->
      return unless scope.$parent.jsonTheme.settings

      return scope.$parent.jsonTheme.settings.find (item) ->
        return unless item.scope

        item_scopes = item.scope.split(', ')

        match = item_scopes.filter (item_scope) ->
          item_scopes_arr = item_scope.split('.')
          active_scope_arr = active_scope.split('.')

          return (item_scopes_arr.subtract active_scope_arr).length < 1

        return item if match.length
