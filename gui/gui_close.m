function gui_close
% User-defined GUI close request function 
% to display a question dialog box 
% Save and Load are possible
   selection = questdlg('All unsaved changes will be lost. Are you sure?',...
      'Close Request',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         uiresume(gcf)
      case 'No'
      return 
   end
end